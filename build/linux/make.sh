#!/bin/sh

DIST_ARCHIVE=arm-2010q1-188-arm-none-eabi-toolchain-linux32.tar.gz
DIST_URL=http://static.leaflabs.com/pub/codesourcery/

# Set JAVA_HOME only if it is blank
# Modify this if you aren't using java-6-sun; needed for lib/tools.jar
JAVA_HOME=${JAVA_HOME:="/usr/lib/jvm/java-6-sun/"}

### -- SETUP DIST FILES ----------------------------------------

# Have we extracted the dist files yet?
if test ! -d dist/tools/arm
then
  # Have we downloaded the dist files yet? 
  if test ! -f $DIST_ARCHIVE
  then
    echo "Downloading distribution files for linux platform: " $DIST_ARCHIVE
    wget $DIST_URL/$DIST_ARCHIVE
    if test ! -f $DIST_ARCHIVE
    then 
      echo "!!! Problem downloading distribution files; please fetch zip file manually and put it here: "
      echo `pwd`
      exit 1
    fi
  fi
  echo "Extracting distribution files for linux platform: " $DIST_ARCHIVE
  tar --extract --file=$DIST_ARCHIVE --ungzip --directory=dist/tools/
  if test ! -d dist/tools/arm
  then
    echo "!!! Problem extracting dist file, please fix it."
    exit 1
  fi
fi

### -- SETUP WORK DIR -------------------------------------------

if test -d work
then
  BUILD_PREPROC=false
else
  echo Setting up directories to build for Linux...
  BUILD_PREPROC=true

  mkdir work
  cp -r ../shared/lib work/
  cp -r ../../libraries work/
  cp -r ../shared/tools work/

  cp -r ../../hardware work/

  cp ../../app/lib/antlr.jar work/lib/
  cp ../../app/lib/ecj.jar work/lib/
  cp ../../app/lib/jna.jar work/lib/
  cp ../../app/lib/oro.jar work/lib/
  cp ../../README-dist work/README.txt

  echo Copying examples...
  cp -r ../shared/examples work/

  #echo Extracting reference...
  #unzip -q -d work/ ../shared/reference.zip
  echo Copying reference...
  cp -r ../shared/reference work/

  echo Copying tools...
  cp -r dist/tools work/hardware/
  mv work/hardware/tools/dfu-util work/hardware/tools/arm/bin

  cp dist/45-maple.rules work/tools/
  install -m 755 dist/maple-ide work/maple-ide
  install -m 755 dist/install-udev-rules.sh work/install-udev-rules.sh

  echo NOT extracting full JRE... will attempt to use system-wide version

  ARCH=`uname -m`
  if [ $ARCH = "i686" ]
  then
    echo Using 32-bit librxtxSerial.so
    cp dist/lib/librxtxSerial.so.i386 work/lib/librxtxSerial.so
    cp dist/lib/RXTXcomm.jar.i386 work/lib/RXTXcomm.jar
  else 
    echo Using 64-bit librxtxSerial.so
    cp dist/lib/librxtxSerial.so.x86_64 work/lib/librxtxSerial.so
    cp dist/lib/RXTXcomm.jar.x86_64 work/lib/RXTXcomm.jar
  fi
fi

cd ../..


### -- BUILD CORE ----------------------------------------------


echo Building processing.core

cd core

#CLASSPATH="../build/linux/work/java/lib/rt.jar"
#export CLASSPATH

perl preproc.pl
mkdir -p bin
javac -d bin -source 1.5 -target 1.5 \
    src/processing/core/*.java src/processing/xml/*.java
#find bin -name "*~" -exec rm -f {} ';'
rm -f ../build/linux/work/lib/core.jar
cd bin && zip -rq ../../build/linux/work/lib/core.jar \
  processing/core/*.class processing/xml/*.class && cd ..

# back to base processing dir
cd ..


### -- BUILD PDE ------------------------------------------------

cd app

rm -rf ../build/linux/work/classes
mkdir ../build/linux/work/classes

javac -source 1.5 -target 1.5 \
    -classpath ../build/linux/work/lib/core.jar:../build/linux/work/lib/antlr.jar:../build/linux/work/lib/ecj.jar:../build/linux/work/lib/jna.jar:../build/linux/work/lib/oro.jar:../build/linux/work/lib/RXTXcomm.jar:$JAVA_HOME/lib/tools.jar \
    -d ../build/linux/work/classes \
    src/processing/app/*.java \
    src/processing/app/debug/*.java \
    src/processing/app/linux/*.java \
    src/processing/app/preproc/*.java \
    src/processing/app/syntax/*.java \
    src/processing/app/tools/*.java

cd ../build/linux/work/classes
rm -f ../lib/pde.jar
zip -0rq ../lib/pde.jar .
cd ../../../..


echo
echo Done.

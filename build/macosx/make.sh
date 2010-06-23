#!/bin/sh

# http://dev.processing.org/bugs/show_bug.cgi?id=1179
OSX_VERSION=`sw_vers | grep ProductVersion | awk '{print $2}' | awk '{print substr($0,1,4)}'`

DIST_ARCHIVE=arm-2010q1-188-arm-none-eabi-toolchain-macosx32.tar.gz
DIST_URL=http://static.leaflabs.com/pub/codesourcery

### -- SETUP DIST FILES ----------------------------------------

# Have we extracted the dist files yet?
if test ! -d dist/tools/arm
then
  # Have we downloaded the dist files yet? 
  if test ! -f $DIST_ARCHIVE
  then
    echo "Downloading distribution files for macosx platform: " $DIST_ARCHIVE
    wget $DIST_URL/$DIST_ARCHIVE
    if test ! -f $DIST_ARCHIVE
    then
      echo "!!! Problem downloading distribution files; please fetch zip file manually and put it here: "
      echo `pwd`
      exit 1
    fi
  fi
  echo "Extracting distribution files for macosx platform: " $DIST_ARCHIVE
  tar -xzf $DIST_ARCHIVE --directory=dist/tools
  if test ! -d dist/tools/arm
  then
    echo "!!! Problem extracting dist file, please fix it."
    exit 1
  fi
fi

### -- SETUP WORK DIR -------------------------------------------

RESOURCES=`pwd`/work/MapleIDE.app/Contents/Resources/Java
#echo $RESOURCES
#exit

if test -d work
then
  BUILD_PREPROC=false
else
  echo Setting up directories to build under Mac OS X
  BUILD_PREPROC=true

  mkdir work

  # to have a copy of this guy around for messing with
  echo Copying MapleIDE.app...
  #cp -a dist/MapleIDE.app work/   # #@$(* bsd switches
  #/sw/bin/cp -a dist/MapleIDE.app work/
  cp -pR dist/MapleIDE.app work/
  # cvs doesn't seem to want to honor the +x bit 
  chmod +x work/MapleIDE.app/Contents/MacOS/JavaApplicationStub

  cp -r ../shared/lib "$RESOURCES/"
  cp -r ../../libraries "$RESOURCES/"
  cp -r ../shared/tools "$RESOURCES/"

  cp -r ../../hardware "$RESOURCES/"

  cp ../../app/lib/antlr.jar "$RESOURCES/"
  cp ../../app/lib/ecj.jar "$RESOURCES/"
  cp ../../app/lib/jna.jar "$RESOURCES/"
  cp ../../app/lib/oro.jar "$RESOURCES/"
  cp ../../app/lib/RXTXcomm.jar "$RESOURCES/"
  cp ../../README-dist "$RESOURCES/README.txt"

  echo Copying examples...
  cp -r ../shared/examples "$RESOURCES/"

  #echo Extracting reference...
  #unzip -q -d "$RESOURCES/" ../shared/reference.zip
  echo Copying reference...
  cp -r ../shared/reference "$RESOURCES/"
  cp ../../readme-arduino.txt "$RESOURCES/reference/"

  echo Copying arm tools...
  mkdir -p "$RESOURCES/hardware/tools/arm"
  cp -r dist/tools/arm/* "$RESOURCES/hardware/tools/arm/" 

  echo Copying dfu-util...
  cp dist/tools/dfu-util work/MapleIDE.app/Contents/Resources/Java/hardware/tools/arm/bin
  mkdir -p  work/MapleIDE.app/Contents/Resources/Java/hardware/tools/arm/Resources
  cp -R dist/tools/libusb-0.1.4.dylib work/MapleIDE.app/Contents/Resources/Java/hardware/tools/arm/Resources
fi


### -- START BUILDING -------------------------------------------

# move to root 'processing' directory
cd ../..


### -- BUILD CORE ----------------------------------------------

echo Building processing.core...

cd core

#CLASSPATH=/System/Library/Frameworks/JavaVM.framework/Classes/classes.jar:/System/Library/Frameworks/JavaVM.framework/Classes/ui.jar:/System/Library/Java/Extensions/QTJava.zip
#export CLASSPATH

perl preproc.pl

mkdir -p bin
javac -source 1.5 -target 1.5 -d bin \
  src/processing/core/*.java \
  src/processing/xml/*.java

rm -f "$RESOURCES/core.jar"

cd bin && \
  zip -rq "$RESOURCES/core.jar" \
  processing/core/*.class \
  processing/xml/*.class \
  && cd ..

# head back to "processing/app"
cd ../app



### -- BUILD PDE ------------------------------------------------

echo Building the PDE...

# For some reason, javac really wants this folder to exist beforehand.
rm -rf ../build/macosx/work/classes
mkdir ../build/macosx/work/classes
# Intentionally keeping this separate from the 'bin' folder
# used by eclipse so that they don't cause conflicts.

javac \
    -Xlint:deprecation \
    -source 1.5 -target 1.5 \
    -classpath "$RESOURCES/core.jar:$RESOURCES/antlr.jar:$RESOURCES/ecj.jar:$RESOURCES/jna.jar:$RESOURCES/oro.jar:$RESOURCES/RXTXcomm.jar" \
    -d ../build/macosx/work/classes \
    src/processing/app/*.java \
    src/processing/app/debug/*.java \
    src/processing/app/macosx/*.java \
    src/processing/app/preproc/*.java \
    src/processing/app/syntax/*.java \
    src/processing/app/tools/*.java

cd ../build/macosx/work/classes
rm -f "$RESOURCES/pde.jar"
zip -0rq "$RESOURCES/pde.jar" .
cd ../..

# get updated core.jar and pde.jar; also antlr.jar and others
#mkdir -p work/MapleIDE.app/Contents/Resources/Java/
#cp work/lib/*.jar work/MapleIDE.app/Contents/Resources/Java/


echo
echo Done.

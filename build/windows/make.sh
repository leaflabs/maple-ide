#!/bin/sh

DIST_ARCHIVE=arm-2010q1-188-arm-none-eabi-toolchain-win32.tar.gz
DIST_URL=http://static.leaflabs.com/pub/codesourcery

JAVA_ARCHIVE=sun-java6-jre-win32.tar.gz
JAVA_URL=http://static.leaflabs.com/pub/java

### -- SETUP DIST FILES ----------------------------------------

# Have we extracted the arm files yet?
if test ! -d dist/tools/arm
then 
  # Have we downloaded the arm files yet? 
  if test ! -f $DIST_ARCHIVE
  then
    echo "Downloading arm toolchain files for windows platform: " $DIST_ARCHIVE
    wget $DIST_URL/$DIST_ARCHIVE
    if test ! -f $DIST_ARCHIVE
    then 
      echo "!!! Problem downloading distribution files; please fetch zip file manually and put it here: "
      echo `pwd`
      exit 1
    fi
  fi  
  echo "Extracting distribution files for windows platform: " $DIST_ARCHIVE
  tar --extract --file=$DIST_ARCHIVE --ungzip --directory=dist/tools
  if test ! -d dist/tools/arm
  then
    echo "!!! Problem extracting arm toolchain file, please fix it."
    exit 1
  fi
fi 

# Have we extracted the javafiles yet?
if test ! -d dist/java
then 
  # Have we downloaded the java files yet? 
  if test ! -f $JAVA_ARCHIVE
  then
    echo "Downloading java toolchain files for windows platform: " $JAVA_ARCHIVE
    wget $JAVA_URL/$JAVA_ARCHIVE
    if test ! -f $JAVA_ARCHIVE
    then 
      echo "!!! Problem downloading distribution files; please fetch zip file manually and put it here: "
      echo `pwd`
      exit 1
    fi
  fi  
  echo "Extracting distribution files for windows platform: " $DIST_ARCHIVE
  tar --extract --file=$JAVA_ARCHIVE --ungzip --directory=dist
  if test ! -d dist/java
  then
    echo "!!! Problem extracting java JRE file, please fix it."
    exit 1
  fi
fi 

### -- SETUP WORK DIR -------------------------------------------

if test -d work
then
  BUILD_PREPROC=false
else
  echo Setting up directories to build Maple IDE...
  BUILD_PREPROC=true

  mkdir work
  cp -r ../shared/lib work/
  cp -r ../shared/tools work/

  cp dist/*.dll work/
  cp -r dist/drivers work/

  cp -r ../../hardware work/
  cp -r ../../libraries work/
  mkdir work/hardware/tools

  cp ../../app/lib/antlr.jar work/lib/
  cp ../../app/lib/ecj.jar work/lib/
  cp ../../app/lib/jna.jar work/lib/
  cp ../../app/lib/oro.jar work/lib/
  cp ../../app/lib/RXTXcomm.jar work/lib/
  cp ../../README-dist work/README.txt

  echo Copying examples...
  cp -r ../shared/examples work/

  #echo Extracting reference...
  #unzip -q -d work/ ../shared/reference.zip
  echo Copying reference...
  cp -r ../shared/reference work/

  #echo Copying avr tools...
  #cp -r dist/tools/avr work/hardware/tools/avr
  #unzip -q -d work/hardware/ avr_tools.zip

  echo Copying arm tools...
  cp -r dist/tools/arm work/hardware/tools/arm
  #unzip -q -d work/hardware/tools/arm/ arm.zip

  echo Copy dfu-util...
  cp dist/dfu-util.exe work/hardware/tools/arm/bin

  echo Copying enormous JRE...
  cp -r dist/java work/java

  # build the maple-ide.exe bundle
  # there are a few hacks in the source to launch4j-3.0.1
  # to build them, use the following:
  # cd head_src/gui_head && make -f Makefile.win
  cd launcher
  USERPROFILE=../work/ ../work/java/bin/java -jar launch4j/launch4j.jar config.xml
  cp maple-ide.exe ../work/maple-ide.exe
  cd ..

  # chmod +x the crew
  # cygwin requires this because of unknown weirdness
  # it was not formerly this anal retentive
  # with the html, it's necessary on windows for launching reference 
  # from shell/command prompt, which is done internally to view reference
  find work -name "*.html" -exec chmod +x {} ';'
  find work -name "*.dll" -exec chmod +x {} ';'
  find work -name "*.exe" -exec chmod +x {} ';'
  find work -name "*.html" -exec chmod +x {} ';'
fi

cd ../..


### -- BUILD CORE ----------------------------------------------

echo Building processing.core...

cd core

#CLASSPATH="..\\build\\windows\\work\\java\\lib\\rt.jar;..\\build\\windows\\work\\java\\lib\\tools.jar"
#CLASSPATH="..\\build\\windows\\work\\java\\lib\\tools.jar"
#export CLASSPATH

perl preproc.pl

mkdir -p bin
../build/windows/work/java/bin/java \
    -classpath "..\\build\\windows\\work\\java\\lib\\tools.jar" \
    com.sun.tools.javac.Main \
    -source 1.5 -target 1.5 -d bin \
    src/processing/core/*.java src/processing/xml/*.java

rm -f ../build/windows/work/lib/core.jar

# package this folder into core.jar
cd bin && zip -rq ../../build/windows/work/lib/core.jar \
  processing/core/*.class processing/xml/*.class && cd ..

# back to base processing dir
cd ..



### -- BUILD PDE ------------------------------------------------

echo Building the PDE...

cd app

# has to be present, otherwise javac will complain of file writing errors
rm -rf ../build/windows/work/classes
mkdir ../build/windows/work/classes

../build/windows/work/java/bin/java \
    -classpath "..\\build\\windows\\work\\java\\lib\\tools.jar" \
    com.sun.tools.javac.Main \
    -source 1.5 -target 1.5 \
    -classpath "..\\build\\windows\\work\\lib\\core.jar;..\\build\\windows\\work\\lib\antlr.jar;..\\build\\windows\\work\\lib\\ecj.jar;..\\build\\windows\\work\\lib\\jna.jar;..\\build\\windows\\work\\lib\\oro.jar;..\\build\\windows\\work\\lib\\RXTXcomm.jar;..\\build\\windows\\work\\java\\lib\\tools.jar" \
    -d ..\\build\\windows\\work\\classes \
    src/processing/app/*.java \
    src/processing/app/debug/*.java \
    src/processing/app/syntax/*.java \
    src/processing/app/preproc/*.java \
    src/processing/app/tools/*.java \
    src/processing/app/windows/*.java

cd ../build/windows/work/classes
rm -f ../lib/pde.jar
zip -rq ../lib/pde.jar .
cd ../..


echo
echo Done.


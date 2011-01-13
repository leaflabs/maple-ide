#!/bin/sh

REVISION=`../shared/gen-version-string`

RELEASE=$REVISION
echo Creating Arduino distribution for revision $REVISION...

ARCH=`uname -m`

echo Removing old work directory, etc.

# remove any old boogers
rm -rf arduino
rm -rf arduino-*
rm -rf Arduino*
rm -rf work

echo Rerunning make.sh...
./make.sh

echo Finished with make.sh.  Packaging release.

mkdir arduino
cp -r ../shared/lib arduino/
cp -r ../shared/tools arduino/
cp ../../app/lib/antlr.jar arduino/lib/
cp ../../app/lib/ecj.jar arduino/lib/
cp ../../app/lib/jna.jar arduino/lib/
cp ../../app/lib/oro.jar arduino/lib/
cp ../../README-dist arduino/README.txt

cp -r ../../hardware arduino/
cp -r ../../libraries arduino/

cp -r dist/tools arduino/hardware
mv arduino/hardware/tools/dfu-util arduino/hardware/tools/arm/bin
cp work/tools/45-maple.rules arduino/tools

# write the release version number into the output directory
echo $REVISION > arduino/lib/build-version.txt

echo Copying examples...
cp -r ../shared/examples arduino/

#echo Extracting reference...
#unzip -q -d arduino/ ../shared/reference.zip
echo Copying reference...
cp -r ../shared/reference arduino/
cp ../../readme-arduino.txt arduino/reference/

# add java (jre) files
#tar --extract --file=jre.tgz --ungzip --directory=arduino

echo Copying and renaming other stuff...
# grab pde.jar and export from the working dir
cp work/lib/pde.jar arduino/lib/
cp work/lib/core.jar arduino/lib/

# get platform-specific goodies from the dist dir
install -m 755 dist/maple-ide arduino/maple-ide
install -m 755 dist/install-udev-rules.sh arduino/install-udev-rules.sh

# make sure notes.txt is unix LFs
# the 2> is because the app is a little chatty
dos2unix arduino/readme.txt 2> /dev/null
dos2unix arduino/lib/preferences.txt 2> /dev/null

# remove boogers
find arduino -name "*~" -exec rm -f {} ';'
find arduino -name ".DS_Store" -exec rm -f {} ';'
find arduino -name "._*" -exec rm -f {} ';'
find arduino -name "Thumbs.db" -exec rm -f {} ';'

# zip it all up for release
echo Creating tarball and finishing...
P5=maple-ide-$RELEASE
mv arduino $P5
echo Using 64-bit librxtxSerial.so
cp dist/lib/librxtxSerial.so.x86_64 $P5/lib/librxtxSerial.so
cp dist/lib/RXTXcomm.jar.x86_64 $P5/lib/RXTXcomm.jar

tar cfz $P5-linux64.tgz $P5
# nah, keep the new directory around
#rm -rf $P5

echo Done with 64bit.

echo Using 32-bit librxtxSerial.so
cp dist/lib/librxtxSerial.so.i386 $P5/lib/librxtxSerial.so
cp dist/lib/RXTXcomm.jar.i386 $P5/lib/RXTXcomm.jar
tar cfz $P5-linux32.tgz $P5
echo Done with 32bit.


#!/bin/sh

REVISION=`../shared/gen-version-string`

RELEASE=$REVISION
echo Creating Arduino distribution for revision $REVISION...

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

cp dist/*.dll arduino/
cp -r dist/drivers arduino/

cp -r ../../hardware arduino/
cp -r ../../libraries arduino/
mkdir arduino/hardware/tools/

# write the release version number into the output directory
echo $REVISION > arduino/lib/build-version.txt

cp ../../app/lib/antlr.jar arduino/lib/
cp ../../app/lib/ecj.jar arduino/lib/
cp ../../app/lib/jna.jar arduino/lib/
cp ../../app/lib/oro.jar arduino/lib/
cp ../../app/lib/RXTXcomm.jar arduino/lib/

cp ../../README-dist arduino/README.txt

echo Copying examples...
cp -r ../shared/examples arduino/

#echo Extracting reference...
#unzip -q -d arduino/ ../shared/reference.zip
echo Copying reference...
cp -r ../shared/reference arduino/
cp ../../readme-arduino.txt arduino/reference/

echo Copying binaries...
#cp -r dist/tools/avr arduino/hardware/tools/avr
cp -r dist/tools/arm arduino/hardware/tools/arm
#unzip -q -d arduino/hardware/tools/arm arm.zip
cp dist/dfu-util.exe arduino/hardware/tools/arm/bin
cp dist/dfu-util.exe arduino/ # TODO: both places?

# add java (jre) files
#unzip -q -d arduino jre.zip
cp -r dist/java arduino/java

# get platform-specific goodies from the dist dir
cp launcher/maple-ide.exe arduino/maple-ide.exe

# grab pde.jar and export from the working dir
cp work/lib/pde.jar arduino/lib/
cp work/lib/core.jar arduino/lib/

echo Converting and renaming and cleaning...
# convert revisions.txt to windows LFs
# the 2> is because the app is a little chatty
unix2dos arduino/readme.txt 2> /dev/null
unix2dos arduino/lib/preferences.txt 2> /dev/null
unix2dos arduino/lib/keywords.txt 2> /dev/null

# remove boogers
find arduino -name "*.bak" -exec rm -f {} ';'
find arduino -name "*~" -exec rm -f {} ';'
find arduino -name ".DS_Store" -exec rm -f {} ';'
find arduino -name "._*" -exec rm -f {} ';'
find arduino -name "Thumbs.db" -exec rm -f {} ';'

# chmod +x the crew
find arduino -name "*.html" -exec chmod +x {} ';'
find arduino -name "*.dll" -exec chmod +x {} ';'
find arduino -name "*.exe" -exec chmod +x {} ';'
find arduino -name "*.html" -exec chmod +x {} ';'

# zip it all up for release
echo Packaging standard release...
echo
release_string=maple-ide-$REVISION
mv arduino $release_string
zip -rq $release_string-windowsxp32.zip $release_string
# nah, keep the new directory around
#rm -rf $P5

echo Done.


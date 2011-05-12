#!/bin/bash

REVISION=`../shared/gen-version-string`
BUILD_DIR=work

echo Creating Maple IDE distribution for revision $REVISION

echo Removing old build directory $BUILD_DIR
rm -rf $BUILD_DIR

echo Rerunning make.sh...
./make.sh

echo Finished with make.sh.  Packaging release.

cp -r ../shared/lib $BUILD_DIR
cp -r ../shared/tools $BUILD_DIR

cp dist/*.dll $BUILD_DIR
cp -r dist/drivers $BUILD_DIR

cp -r ../../hardware $BUILD_DIR
cp -r ../../libraries $BUILD_DIR

# write the release version number into the output directory
echo $REVISION > $BUILD_DIR/lib/build-version.txt

cp ../../app/lib/antlr.jar $BUILD_DIR/lib/
cp ../../app/lib/ecj.jar $BUILD_DIR/lib/
cp ../../app/lib/jna.jar $BUILD_DIR/lib/
cp ../../app/lib/oro.jar $BUILD_DIR/lib/
cp ../../app/lib/RXTXcomm.jar $BUILD_DIR/lib/

cp ../../README-dist $BUILD_DIR/README.txt

echo Copying examples...
cp -r ../shared/examples $BUILD_DIR/

#echo Extracting reference...
#unzip -q -d arduino/ ../shared/reference.zip
echo Copying reference...
cp -r ../shared/reference $BUILD_DIR/

echo Copying binaries...
cp -r dist/tools/arm $BUILD_DIR/hardware/tools/arm
cp dist/dfu-util.exe $BUILD_DIR/hardware/tools/arm/bin
cp dist/dfu-util.exe $BUILD_DIR/ # FIXME: both places?

# add java (jre) files
cp -r dist/java $BUILD_DIR/java

# get platform-specific goodies from the dist dir
cp launcher/maple-ide.exe $BUILD_DIR/maple-ide.exe

echo Converting and renaming and cleaning...
# convert to Windows line endings
# the 2> is because the app is a little chatty
unix2dos $BUILD_DIR/readme.txt 2> /dev/null
unix2dos $BUILD_DIR/lib/preferences.txt 2> /dev/null
unix2dos $BUILD_DIR/lib/keywords.txt 2> /dev/null

# chmod +x the crew
# cygwin requires this because of unknown weirdness
# it was not formerly this anal retentive
# with the html, it's necessary on windows for launching reference 
# from shell/command prompt, which is done internally to view reference
find $BUILD_DIR -name "*.html" -exec chmod +x {} ';'
find $BUILD_DIR -name "*.dll" -exec chmod +x {} ';'
find $BUILD_DIR -name "*.exe" -exec chmod +x {} ';'
find $BUILD_DIR -name "*.html" -exec chmod +x {} ';'

# zip it all up for release

echo release is ready to zip.  windows line endings means you need to do this by hand.  sorry.

# mv $BUILD_DIR $RELEASE_STRING
# zip -rq $RELEASE_STRING.zip $RELEASE_STRING

echo Done.

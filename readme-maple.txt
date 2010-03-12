

Disclaimer
------------------------------------------------------------------------------
We make no claims that we "preserve" any design or strategy behind arduino,
which is why this being released as a separate branch of arduino and not as a
patch. Arduino is clearly organized around compiling to avr, and compiling to
arm is more of a hack.


Requirements
------------------------------------------------------------------------------

A number of file archives are not included in this repository and must be 
downloaded and copied in seperately:

avr_tools.zip           ./build/windows/avr_tools.zip
jre.tgz                 ./build/linux/jre.tgz
jre.zip                 ./build/windows/jre.zip
reference.zip           ./build/shared/reference.zip
template.dmg.gz         ./build/macosx/template.dmg.gz
tools-universal.zip     ./build/macosx/dist/tools-universal.zip


Changes from stock arduino codebase
------------------------------------------------------------------------------
 * removed all Eclipse project cruft
 * hardware/leaflabs directory, including bootloader/ and core/
 * app/src/processing/app/Base.java: add getArmBasePath
 * app/src/processing/app/Sketch.java: imports, compiler/uploader selection
 * app/src/processing/app/debug/Sizer.java: don't try to size make builds
 * app/src/processing/app/debug/DFUUploader.java: new dfu-util uploader
 * app/src/processing/app/debug/Compiler.java: expose a couple methods
 * app/src/processing/app/debug/ArmCompiler.java: new, extends Compiler
 * build/macosx/dist/Arduino.app/Contents/Resources/processing.icns,
   build/shared/lib: UI skin and preferences


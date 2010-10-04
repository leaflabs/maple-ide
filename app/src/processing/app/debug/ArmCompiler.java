/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */

/*

  Modified version of Compiler.java, which is...

  Part of the Processing project - http://processing.org

  Copyright (c) 2004-08 Ben Fry and Casey Reas
  Copyright (c) 2001-04 Massachusetts Institute of Technology

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

package processing.app.debug;

import processing.app.debug.Compiler;
import processing.app.Base;
import processing.app.Preferences;
import processing.app.Sketch;
import processing.app.SketchCode;
import processing.core.*;

import java.io.*;
import java.util.*;
import java.util.zip.*;


public class ArmCompiler extends Compiler {

  public ArmCompiler() { }

  private boolean messagesNonError = false; // THIS IS SUCH A HACK.
  private List<String> hackErrors = null;

  // well, if we're using fields as a global variable hack, we might
  // as well be consistent
  private Map<String, String> boardPrefs;
  private File corePath;

  /**
   * Compile for ARM with make
   *
   * @param sketch Sketch object to be compiled.
   * @param buildPath Where the temporary files live and will be built from.
   * @param primaryClassName the name of the combined sketch file w/ extension
   * @return true if successful.
   * @throws RunnerException iff there's a problem.
   */
  @Override
    public boolean compile
    (Sketch sketch, String buildPath, String primaryClassName,
     boolean verbose, List<String> compileErrors)
    throws RunnerException {

    this.sketch = sketch;
    this.buildPath = buildPath;
    createFolder(new File(buildPath));
    this.primaryClassName = primaryClassName;
    this.verbose = verbose;
    this.hackErrors = compileErrors;
    // the pms object isn't used for anything but storage
    MessageStream pms = new MessageStream(this);

    try {
      this.boardPrefs = Base.getBoardPreferences();
    } catch (NullPointerException npe) {
      Base.showWarning("No board selected",
                       "please choose one from the Tools menu.",
                       npe);
      return false;
    }

    String core = boardPrefs.get("build.core");
    if (core.indexOf(':') == -1) {
      Target t = Base.getTarget();
      File coreFolder = new File(new File(t.getFolder(), "cores"), core);
      this.corePath = new File(coreFolder.getAbsolutePath());
    } else {
      Target t = Base.targetsTable.get(core.substring(0, core.indexOf(':')));
      File coresFolder = new File(t.getFolder(), "cores");
      File coreFolder = new File(coresFolder,
                                 core.substring(core.indexOf(':') + 1));
      this.corePath = new File(coreFolder.getAbsolutePath());
    }

    List<File> objectFiles = new ArrayList<File>();
    List<File> includePaths = new ArrayList<File>(Arrays.asList(corePath));


    // 1. compile the core (e.g. libmaple for a Maple target),
    // outputting .o files to buildPath.
    System.out.print("\tCompiling core...\n");
    objectFiles.addAll(compileFiles(buildPath, includePaths,
                                    corePath.getAbsolutePath(), true));

    // 2. compile the libraries, updating includePaths as necessary.
    objectFiles.addAll(compileLibraries(includePaths));

    // 3. compile the sketch (already in the buildPath)
    System.out.println("\tCompiling the sketch...");
    objectFiles.addAll(compileFiles(buildPath, includePaths,
                                    buildPath, false));

    // 4. link it all together into the .bin file
    File binFile = linkFiles(objectFiles);

    // 5. compute binary sizes and report to user
    sizeBinary(binFile);

    return true;
  }

  /**
   * @return List of object paths created as a result of compilation.
   */
  private List<File> compileFiles(String buildPath, List<File> includePaths,
                                  String sourcePath, boolean recurse)
    throws RunnerException {

    // getCommandCompilerFoo will destructively modify objectPaths
    // with any object files the command produces.
    List<File> objectPaths = new ArrayList<File>();

    // Compile assembly files
    for (File file : findFilesInPath(sourcePath, "S", recurse)) {
      execAsynchronously(getCommandCompilerS(includePaths,
                                             file.getAbsolutePath(),
                                             buildPath,
                                             objectPaths));
    }

    // Compile C files
    for (File file : findFilesInPath(sourcePath, "c", recurse)) {
      execAsynchronously(getCommandCompilerC(includePaths,
                                             file.getAbsolutePath(),
                                             buildPath,
                                             objectPaths));
    }

    // Compile C++ files
    for (File file : findFilesInPath(sourcePath, "cpp", recurse)) {
      execAsynchronously(getCommandCompilerCPP(includePaths,
                                               file.getAbsolutePath(),
                                               buildPath,
                                               objectPaths));
    }

    return objectPaths;
  }

  /**
   * Destructively modifies includePaths to reflect any library
   * includes, which will be of the form
   *   <buildPath>/<library>/
   *
   * @return List of object files created.
   */
  private List<File> compileLibraries(List<File> includePaths)
    throws RunnerException {

    List<File> objectFiles = new ArrayList<File>();

    List<File> importedLibs = sketch.getImportedLibraries();
    if (!importedLibs.isEmpty()) {
      List<String> libNames = new ArrayList<String>();
      for (File lib: importedLibs) libNames.add(lib.getName());
      String libString = libNames.toString();
      libString = libString.substring(1, libString.length()-1);
      System.out.println("\tCompiling libraries: " + libString);

      // use library directories as include paths for all libraries
      includePaths.addAll(importedLibs);

      for (File libraryFolder: importedLibs) {
        File outputFolder = new File(buildPath, libraryFolder.getName());
        File utilityFolder = new File(libraryFolder, "utility");
        createFolder(outputFolder);
        // libraries can have private includes in their utility/ folders
        includePaths.add(utilityFolder);

        objectFiles.addAll
          (compileFiles(outputFolder.getAbsolutePath(), includePaths,
                        libraryFolder.getAbsolutePath(), false));

        outputFolder = new File(outputFolder, "utility");
        createFolder(outputFolder);

        objectFiles.addAll
          (compileFiles(outputFolder.getAbsolutePath(), includePaths,
                        utilityFolder.getAbsolutePath(), false));

        // other libraries should not see this library's utility/ folder
        includePaths.remove(includePaths.size() - 1);
      }
    } else {
      System.out.println("\tNo libraries to compile.");
    }

    return objectFiles;
  }

  /**
   * Runs the linker script on the compiled sketch.
   * @return the .bin file generated by the linker script.
   */
  private File linkFiles(List<File> objectFiles) throws RunnerException {
    System.out.println("\tLinking...");

    File linkerScript = new File(corePath, boardPrefs.get("build.linker"));
    File elf = new File(buildPath, primaryClassName + ".elf");
    File bin = new File(buildPath, primaryClassName + ".bin");

    // Run the linker
    List<String> linkCommand = new ArrayList<String>
      (Arrays.asList
       (Base.getArmBasePath() + "arm-none-eabi-g++",
        "-T" + linkerScript.getAbsolutePath(),
        "-L" + corePath.getAbsolutePath(),
        "-mcpu=cortex-m3",
        "-mthumb",
        "-Xlinker",
        "--gc-sections",
        "--print-gc-sections",
        "--march=armv7-m",
        "-Wall",
        "-o", elf.getAbsolutePath()));

    for (File f: objectFiles) linkCommand.add(f.getAbsolutePath());

    linkCommand.add("-L" + buildPath);

    execAsynchronously(linkCommand);

    // Run objcopy
    List<String> objcopyCommand = new ArrayList<String>
      (Arrays.asList
       (Base.getArmBasePath() + "arm-none-eabi-objcopy",
        "-v",
        "-Obinary",
        elf.getAbsolutePath(),
        bin.getAbsolutePath()));

    execAsynchronously(objcopyCommand);

    return bin;
  }

  private void sizeBinary(File binFile) throws RunnerException {
    System.out.println("\tComputing sketch size...");

    List<String> command = new ArrayList<String>
      (Arrays.asList(Base.getArmBasePath() + "arm-none-eabi-size",
                     "--target=binary",
                     "-A",
                     binFile.getAbsolutePath()));

    messagesNonError = true;
    System.out.println();
    execAsynchronously(command);
    messagesNonError = false;
  }

  /////////////////////////////////////////////////////////////////////////////

  private List<String> getCommandCompilerS
    (List<File> includePaths, String sourceName, String buildPath,
     List<File> hackObjectPaths) {

    String buildBase = getBuildBase(sourceName);
    File depsFile = new File(buildBase + ".d");
    File objFile = new File(buildBase + ".o");

    hackObjectPaths.add(objFile);

    List<String> command = new ArrayList<String>();

    command.addAll
      (Arrays.asList
       (Base.getArmBasePath() + "arm-none-eabi-gcc",
        "-mcpu=cortex-m3",
        "-march=armv7-m",
        "-mthumb",
        "-DBOARD_" + boardPrefs.get("build.board"),
        "-DMCU_" + boardPrefs.get("build.mcu"),
        "-x", "assembler-with-cpp",
        "-o", objFile.getAbsolutePath(),
        "-c",
        sourceName));

    return command;
  }


  private List<String> getCommandCompilerC
    (List<File> includePaths, String sourceName, String buildPath,
     List<File> hackObjectPaths) {

    String buildBase = getBuildBase(sourceName);
    File depsFile = new File(buildBase + ".d");
    File objFile = new File(buildBase + ".o");

    hackObjectPaths.add(objFile);

    List<String> command = new ArrayList<String>();

    command.addAll
      (Arrays.asList
       (Base.getArmBasePath() + "arm-none-eabi-gcc",
        "-Os",
        "-g",
        "-mcpu=cortex-m3",
        "-mthumb",
        "-march=armv7-m",
        "-nostdlib",
        "-ffunction-sections",
        "-fdata-sections",
        "-Wl,--gc-sections",
        "-DBOARD_" + boardPrefs.get("build.board"),
        "-DMCU_" + boardPrefs.get("build.mcu"),
        "-D" + boardPrefs.get("build.vect"),
        "-DARDUINO=" + Base.REVISION));

    for (File i: includePaths) {
      command.add("-I" + i.getAbsolutePath());
    }

    command.addAll
      (Arrays.asList
       ("-o", objFile.getAbsolutePath(),
        "-c",
        sourceName));

    return command;
  }

  private List<String> getCommandCompilerCPP
    (List<File> includePaths, String sourceName, String buildPath,
     List<File> hackObjectPaths) {

    String buildBase = getBuildBase(sourceName);
    File depsFile = new File(buildBase + ".d");
    File objFile = new File(buildBase + ".o");

    hackObjectPaths.add(objFile);

    List<String> command = new ArrayList<String>();

    command.addAll
      (Arrays.asList
       (Base.getArmBasePath() + "arm-none-eabi-g++",
        "-Os",
        "-g",
        "-mcpu=cortex-m3",
        "-mthumb",
        "-march=armv7-m",
        "-nostdlib",
        "-ffunction-sections",
        "-fdata-sections",
        "-Wl,--gc-sections",
        "-DBOARD_" + boardPrefs.get("build.board"),
        "-DMCU_" + boardPrefs.get("build.mcu")));

    for (File i: includePaths) {
      command.add("-I" + i.getAbsolutePath());
    }

    command.addAll(Arrays.asList("-fno-rtti", "-fno-exceptions", "-Wall"));

    command.addAll
      (Arrays.asList
       ("-o", objFile.getAbsolutePath(),
        "-c",
        sourceName));

    return command;
  }

  private String getBuildBase(String sourceFile) {
    File f = new File(sourceFile);
    String s = f.getName();
    return buildPath + File.separator + s.substring(0, s.lastIndexOf('.'));
  }

  /**
   * Part of the MessageConsumer interface, this is called
   * whenever a piece (usually a line) of error message is spewed
   * out from the compiler. The errors are parsed for their contents
   * and line number, which is then reported back to Editor.
   */
  public void message(String s) {
    // This receives messages as full lines, so a newline needs
    // to be added as they're printed to the console.
    //System.err.print(s);
    this.hackErrors.add(s);
    // SUCH A HACK
    if (messagesNonError) {
      System.out.print(s);
      return;
    }

    // ignore cautions
    if (s.indexOf("warning") != -1) return;

    // ignore this line; the real error is on the next one
    if (s.indexOf("In file included from") != -1) return;

    // ignore obj copy
    if (s.indexOf("copy from ") != -1) return;

    String buildPathSubst = buildPath + File.separatorChar;

    String partialTempPath = null;
    int partialStartIndex = -1; //s.indexOf(partialTempPath);
    int fileIndex = -1;  // use this to build a better exception

    // check the main sketch file first.
    partialTempPath = buildPathSubst + primaryClassName;
    partialStartIndex = s.indexOf(partialTempPath);

    if (partialStartIndex != -1) {
      fileIndex = 0;
    } else {
      // wasn't there, check the other (non-pde) files in the sketch.
      // iterate through the project files to see who's causing the trouble
      for (int i = 0; i < sketch.getCodeCount(); i++) {
        if (sketch.getCode(i).isExtension("pde")) continue;

        partialTempPath = buildPathSubst + sketch.getCode(i).getFileName();
        //System.out.println(partialTempPath);
        partialStartIndex = s.indexOf(partialTempPath);
        if (partialStartIndex != -1) {
          fileIndex = i;
          //System.out.println("fileIndex is " + fileIndex);
          break;
        }
      }
      //+ className + ".java";
    }

    // if the partial temp path appears in the error message...
    //
    //int partialStartIndex = s.indexOf(partialTempPath);
    if (partialStartIndex != -1) {

      // skip past the path and parse the int after the first colon
      //
      String s1 = s.substring(partialStartIndex +
                              partialTempPath.length() + 1);
      //System.out.println(s1);
      int colon = s1.indexOf(':');

      if (s1.indexOf("In function") != -1 || colon == -1) {
        System.err.print(s1);
        //firstErrorFound = true;
        return;
      }

      int lineNumber;
      try {
        lineNumber = Integer.parseInt(s1.substring(0, colon));
      } catch (NumberFormatException e) {
        System.err.print(s1);
        return;
      }

      //System.out.println("pde / line number: " + lineNumber);

      if (fileIndex == 0) {  // main class, figure out which tab
        for (int i = 1; i < sketch.getCodeCount(); i++) {
          if (sketch.getCode(i).isExtension("pde")) {
            if (sketch.getCode(i).getPreprocOffset() < lineNumber) {
              fileIndex = i;
              //System.out.println("i'm thinkin file " + i);
            }
          }
        }
        // OLD to do: DAM: if the lineNumber is less than
        // sketch.getCode(0).getPreprocOffset() we shouldn't subtract
        // anything from it, as the error is above the location where
        // the function prototypes and #include "WProgram.h" were
        // inserted.
        lineNumber -= sketch.getCode(fileIndex).getPreprocOffset();
      }

      //String s2 = s1.substring(colon + 2);
      int err = s1.indexOf(":");
      if (err != -1) {

        // if the first error has already been found, then this must be
        // (at least) the second error found
        if (firstErrorFound) {
          secondErrorFound = true;
          return;
        }

        // if executing at this point, this is *at least* the first error
        firstErrorFound = true;

        err += ":".length();
        String description = s1.substring(err);
        description = description.trim();
        System.err.print(description);

        //System.out.println("description = " + description);
        //System.out.println("creating exception " + exception);
        exception = new RunnerException(description, fileIndex, lineNumber-1, -1, false);

        // NOTE!! major change here, this exception will be queued
        // here to be thrown by the compile() function
        //editor.error(exception);

      } else {
        System.err.println("i suck: " + s);
      }

    } else {
      // this isn't the start of an error line, so don't attempt to parse
      // a line number out of it.

      // if the second error hasn't been discovered yet, these lines
      // are probably associated with the first error message,
      // which is already in the status bar, and are likely to be
      // of interest to the user, so spit them to the console.
      //
      if (!secondErrorFound) {
        System.err.println(s);
      }
    }
  }

}


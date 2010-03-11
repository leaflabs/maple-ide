/* -*- mode: jde; c-basic-offset: 2; indent-tabs-mode: nil -*- */

/*
  DFUUploader - uploader implementation using DFU

  Copyright (c) 2010
  Andrew Meyer

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

import processing.app.Base;
import processing.app.Preferences;
import processing.app.Serial;

import java.io.*;
import java.util.*;
import java.util.zip.*;
import javax.swing.*;
import gnu.io.*;


public class DFUUploader extends Uploader  {
  public DFUUploader() {
  }

  // XXX: add support for uploading sketches using a programmer
  public boolean uploadUsingPreferences(String buildPath, String className, boolean verbose)
  throws RunnerException {
    this.verbose = verbose;
    String uploadUsing = Base.getBoardPreferences().get("upload.using");
    if (uploadUsing == null) {
      // fall back on global preference
      uploadUsing = Preferences.get("upload.using");
    }
    if (uploadUsing.equals("bootloader")) {
      return uploadViaDFU(buildPath, className);
    }

    /* no support for openOCD yet */
    return false;
  }

  public boolean burnBootloader(String programmer) throws RunnerException {
    /* no support for openocd/bootloader overwrite yet */
    return false;
  }

  private boolean uploadViaDFU(String buildPath, String className)
  throws RunnerException {
    /* todo, check for size overruns! */
    String fileType = Base.getBoardPreferences().get("upload.file_type");
    if (fileType == null) {
      /* fall back on default */
      /* this isnt great because is default Avrdude or dfu-util? */
      fileType = Preferences.get("upload.file_type");
    }

    if (fileType.equals("bin")) {
      String usbID = Base.getBoardPreferences().get(".upload.usbID");
      if (usbID == null) {
        /* fall back on default */
        /* this isnt great because is default Avrdude or dfu-util? */
        usbID = Preferences.get("upload.usbID");
      }

      /* todo, add handle to let user choose altIf at upload time! */
      String altIf = Base.getBoardPreferences().get(".upload.altID");

//       commandDownloader.add("hexdump");
//       commandDownloader.add(buildPath+File.separator+className+".bin");
//       executeUploadCommand(commandDownloader);

      List commandDownloader = new ArrayList();
      commandDownloader.add("dfu-util");
      commandDownloader.add("-a "+altIf);
      commandDownloader.add("-R");
      commandDownloader.add("-d "+usbID);
      commandDownloader.add("-D"+ buildPath+File.separator+className+".bin");//"./thisbin.bin");

      return executeUploadCommand(commandDownloader);
    }

    System.err.println("Only .bin files are supported at this time");
    return false;
  }
      
  public boolean dfu(Collection params) throws RunnerException {
    List commandDownloader = new ArrayList();
    commandDownloader.add("dfu-util");
    commandDownloader.addAll(params);

//     commandDownloader = new ArrayList();
//     commandDownloader.add("cp");
//     commandDownloader.add("/home/poslathian/programming/leafGoog/Maple/leaflabs/build_box/build/maple_build.bin");
//     commandDownloader.add("./");
//     executeUploadCommand(commandDownloader);

//     commandDownloader = new ArrayList();
//     commandDownloader.add("hexdump");
//     commandDownloader.add("./maple_build.bin");
//     executeUploadCommand(commandDownloader);

//     commandDownloader = new ArrayList();
//     commandDownloader.add("dfu-util");

//     commandDownloader.add("-D");
//     commandDownloader.add("/home/poslathian/programming/leafGoog/Maple/leaflabs/build_box/build/maple_build.bin");

    return executeUploadCommand(commandDownloader);
  }
}

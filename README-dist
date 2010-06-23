                                    _         _     _      
              _ __ ___   __ _ _ __ | | ___   (_) __| | ___ 
             | '_ ` _ \ / _` | '_ \| |/ _ \  | |/ _` |/ _ \
             | | | | | | (_| | |_) | |  __/  | | (_| |  __/
             |_| |_| |_|\__,_| .__/|_|\___|  |_|\__,_|\___|
                             |_|                              
                                                 by leaflabs!


     For installation instructions and full documentation please open the 
       index.html file in the reference directory/ with a web browser. 


         Updated or more complete documentation may be available at: 
                   http://leaflabs.com/docs/maple-ide/


maple-ide is a graphical programming environment for the Maple development
board developed by LeafLabs; 'IDE' is a common acronym which stands for
"Integrated Development Environment". This software is a modified version of
the popular open source Arduino environment retargeted towards the ARM
Cortex-M3 microcontroller in the Maple; the regular Arduino toolchain is only
targeted towards AVR microcontrollers. 

This IDE includes a full ARM compiler toolchain ("arm-none-eabi-gcc") and a low
level library for the STM32 Cortex-M3 platform called libmaple. libmaple is 
developed separately and can be used straight from the command line; it is
available at: http://github.com/leaflabs/libmaple

License
------------------------------------------------------------------------------
All software included in this archive is open source, which means the original
source code is available in full and that the software can be used, modified,
and redistributed for any purpose with very few restrictions. In the interest
of bandwidth and disk space, this distribution of the IDE contains mostly
compiled binaries; original source code can be found on our website,
leaflabs.com (most code is actually hosted from http://github.com/leaflabs/).

In particular, the IDE software itself (derived from the Arduino IDE) is
covered under the GPL; the libmaple library which makes programming the Maple
microcontroller easier is under the MIT/X11 License; and the GCC toolchain
(including modifications by CodeSourcery) is under a combination of the GPL and
the LGPL. The hardware design of the Maple itself is also available under a
free license: the Creative Commons Attribution Share-A-Like License.

(see http://leaflabs.com/licensing for more details)

Known Issues
------------------------------------------------------------------------------
Menus are often incorrectly rendered the first time you open them, missing
certain drop-down containers like Serial Port, or Examples. They reappear after
reloading the menu bar.

Sometimes syntax highlighting doesn't work quite right in the IDE code editor.
In particular underscores are frequently invisible...

Sometimes DFU reports "no DFU device present" or "Lost device after reset." If
the device is indeed plugged in, then this issue is likely due to finicky
timing between the autoreset and the programming operation. You can adjust this
timing in the preferences panel (in milliseconds). What happens is that after
reset, the programming operation either occurs too soon (dfu bootloader hasn't
booted yet) or too late (bootloader has already begun exit procedure). The
delay in the bootloader is already getting long, so its better to tweak the
delay parameter to what best works on your system.


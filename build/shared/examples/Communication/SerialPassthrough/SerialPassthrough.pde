/*
  Multple serial test

  Receives from Serial1, sends to SerialUSB.

  The circuit:
  * Maple connected over SerialUSB
  * Serial device (e.g. an Xbee radio, another Maple)

  created 30 Dec. 2008
  by Tom Igoe

  Ported to the Maple 27 May 2010 by Bryan Newbold
*/

void setup() {
  // Initialize Serial1:
  Serial1.begin(9600);
}

void loop() {
  // read from Serial1, send over USB:
  if (Serial1.available()) {
    int inByte = Serial1.read();
    SerialUSB.print(inByte, BYTE);
  }
}

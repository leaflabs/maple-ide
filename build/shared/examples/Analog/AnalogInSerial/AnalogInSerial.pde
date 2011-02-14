/*
  Analog input, serial output

  Reads an analog input pin, prints the results to the serial monitor.

  The circuit:

  * Potentiometer connected to analog pin 15.
  * Center pin of the potentiometer goes to the analog pin.
  * Side pins of the potentiometer go to +3.3V and ground

  created over and over again
  by Tom Igoe and everyone who's ever used Arduino

  Ported to Maple 27 May, 2010 by Bryan Newbold
*/

void setup() {
  // Declare pin 15 as INPUT_ANALOG:
  pinMode(15, INPUT_ANALOG);
}

void loop() {
  // read the analog input into a variable:
  int analogValue = analogRead(15);

  // print the result:
  SerialUSB.println(analogValue);
}

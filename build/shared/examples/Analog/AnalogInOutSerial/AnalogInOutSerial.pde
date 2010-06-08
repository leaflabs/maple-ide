/*
  Analog input, analog output, serial output
 
 Reads an analog input pin, maps the result to a range from 0 to 255
 and uses the result to set the pulsewidth modulation (PWM) of an output pin.
 Also prints the results to the serial monitor.
 
 The circuit:
 * potentiometer connected to analog pin 0.
   Center pin of the potentiometer goes to the analog pin.
   side pins of the potentiometer go to +5V and ground
 * LED connected from digital pin 9 to ground
 
 created 29 Dec. 2008
 by Tom Igoe

 Ported to Maple 27 May, 2010 by Bryan Newbold
 
 */

// These constants won't change.  They're used to give names
// to the pins used:
const int analogInPin = 15;  // Analog input pin that the potentiometer is attached to
const int analogOutPin = 9; // Analog output pin that the LED is attached to

int sensorValue = 0;        // value read from the pot
int outputValue = 0;        // value output to the PWM (analog out)

void setup() {
  // USB communications already initialized
}

void loop() {
  // read the analog in value:
  sensorValue = analogRead(analogInPin);            
  // map it to the range of the analog out:
  outputValue = map(sensorValue, 0, 1023, 0, 255);  
  // change the analog out value:
  analogWrite(analogOutPin, outputValue);           

  // print the results to the serial monitor:
  SerialUSB.print("sensor = " );                       
  SerialUSB.print(sensorValue);      
  SerialUSB.print("\t output = ");      
  SerialUSB.println(outputValue);   

  // wait 10 milliseconds before the next loop
  // for the analog-to-digital converter to settle
  // after the last reading:
  delay(10);                     
}

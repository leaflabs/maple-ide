/*
 Fading
 
 This example shows how to fade an LED using the analogWrite() function.
 
 The circuit:
 * LED attached from digital pin 9 to ground.
 
 Created 1 Nov 2008
 By David A. Mellis
 Modified 17 June 2009
 By Tom Igoe

 Modified by LeafLabs to work Maple line boards
 
 http://arduino.cc/en/Tutorial/Fading
 

 Differences from Arduino:

    1) On Arduino, a call to analogWrite(pin,value) will automagically
       configure the pin to be a pwm output.  To minimize the overhead
       of calls to analogWrite() and for symmetry with digitalWrite(),
       Maple requires that the pin be initialized with
       pinMode(pin,PWM)

    2) On Arduino, analogWrite(pin,value) expects 'value' to range
       from 0-255 by default (this means it has 8 bits (that is, 2^8
       steps) of resolution).  On Maple, the default for analogWrite
       is to expect 'value' to range from 0-65535, or 16 bits of
       resolution.

 */


int ledPin = 9;    // connect an LED to digital pin 9

void setup()  { 
  pinMode(ledPin,PWM);  // setup the pin as PWM
} 

void loop()  { 
  
  // fade in from min to max in increments of 1280 points:
  for(int fadeValue = 0 ; fadeValue <= 65535; fadeValue +=1280) { 
    // sets the value (range from 0 to 65535):
    analogWrite(ledPin, fadeValue);         
    // wait for 30 milliseconds to see the dimming effect    
    delay(30);                            
  } 

  // fade out from max to min in increments of 1280 points:
  for(int fadeValue = 65535 ; fadeValue >= 0; fadeValue -=1280) { 
    // sets the value (range from 0 to 1280):
    analogWrite(ledPin, fadeValue);         
    // wait for 30 milliseconds to see the dimming effect    
    delay(30);                            
  } 
}



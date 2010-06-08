
void setup() {
}

void loop() {
  int sensorValue = analogRead(0);
  SerialUSB.println(sensorValue, DEC);
}




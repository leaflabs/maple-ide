
HardwareUsb Serial;

void setup() {
}

void loop() {
  int sensorValue = analogRead(0);
  Serial.println(sensorValue, DEC);
}




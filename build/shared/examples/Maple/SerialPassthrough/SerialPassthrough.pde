void setup() {
  Serial2.begin(9600);
}

void loop() {
  if(SerialUSB.available()) {
    Serial2.write(SerialUSB.read());
  }
  if(Serial2.available()) {
    SerialUSB.write(Serial2.read());
  }
}

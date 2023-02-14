int led = 2;
void setup() {
  pinMode(led, OUTPUT);
  Serial.begin(115200);
}

void loop() {
  digitalWrite(led, HIGH);
  Serial.print("Welcome to IoT Development...");
  delay(1000);

  digitalWrite(led, LOW);
  Serial.println("with ESP32");
  delay(1000);
}



int led = 2;
void setup() {
  pinMode(led, OUTPUT);
  Serial.begin(115200);
}

void loop() {
  digitalWrite(led, HIGH);
  Serial.print("Welcome to IoT Development...");
  delay(200);

  digitalWrite(led, LOW);
  Serial.println("with ESP32");
  delay(200);
}

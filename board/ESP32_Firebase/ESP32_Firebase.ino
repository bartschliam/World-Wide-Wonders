#include <FirebaseESP32.h>
#include <Arduino.h>
#include "BluetoothSerial.h"
#include <TinyGPSPlus.h>
#define LED 2

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

#define WIFI_SSID "VODAFONE-B114"
#define WIFI_PASSWORD "tdE6KAtmqChRYgrX"

// TCD Wifi
// #define WIFI_SSID "TCD-Wifi"
// #define WIFI_PASSWORD "password?"
#define API_KEY "pzmetHjgzVn2I3lSQoevlBWGxZb7eR4h9dfVgGGi"
#define DATABASE_URL "https://iot-bike-lock-default-rtdb.firebaseio.com/" //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app

FirebaseData firebaseData;
BluetoothSerial SerialBT;
TinyGPSPlus gps;
int lastState = 0;

void control_led() {
  if(Firebase.getBool(firebaseData, "/locks/lock0/locked")){
    bool locked = firebaseData.boolData();
    if(locked==true && lastState!=1){ 
      digitalWrite(LED, HIGH); 
      lastState = 1;
      Serial.println("Turned LED on.");
    }
    else if (locked==false && lastState!=2){ 
      digitalWrite(LED, LOW); 
      lastState = 2;
      Serial.println("Turned LED off.");
    }
  }
}

void updateSerial(){
  delay(500);
  while (Serial.available())  {
    Serial2.write(Serial.read());//Forward what Serial received to Software Serial Port
  }
  while (Serial2.available())  {
    Serial.write(Serial2.read());//Forward what Software Serial received to Serial Port
  }
}

void displayInfo()
{
  Serial.print(F("Location: "));
  if (gps.location.isValid()){
    Serial.print(gps.location.lat(), 6);
    Serial.print(F(","));
    Serial.print(gps.location.lng(), 6);
  }
  else
  {
    Serial.print(F("INVALID"));
  }
}

void setup() {
  pinMode(LED, OUTPUT);
  Serial.begin(115200);
  Serial.println();
  Serial.println(__DATE__);
  Serial.println(__TIME__);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println("");
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  Firebase.begin("https://iot-bike-lock-default-rtdb.firebaseio.com/", "pzmetHjgzVn2I3lSQoevlBWGxZb7eR4h9dfVgGGi");
  
  //SerialBT.begin("ESP32 Bike Lock");
  Serial.println("Bluetooth Started! Ready to pair...");
  Serial.println(gps.f_get_position(&flat, &flon, &age));
}

void loop() {
  control_led();
  updateSerial();
  while (Serial2.available() > 0)
    if (gps.encode(Serial2.read()))
      displayInfo();
  if (millis() > 5000 && gps.charsProcessed() < 10)
  {
    Serial.println(F("No GPS detected: check wiring."));
    while (true);
  }
}
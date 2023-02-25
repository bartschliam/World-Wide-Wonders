#include <FirebaseESP32.h>
#include <Arduino.h>
#include "BluetoothSerial.h"
#include <TinyGPSPlus.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#define LED 2

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

#define WIFI_SSID "VODAFONE-B114"
#define WIFI_PASSWORD "tdE6KAtmqChRYgrX"

#define API_KEY "pzmetHjgzVn2I3lSQoevlBWGxZb7eR4h9dfVgGGi"
#define RT_DATABASE_URL "https://iot-bike-lock-default-rtdb.firebaseio.com/" 
#define FS_DATABASE_URL "https://firestore.googleapis.com/v1/projects/iot-bike-lock/databases/(default)/documents/"
//#define FS_DATABASE_URL "https://firestore.googleapis.com/v1/projects/iot-bike-lock/databases/(default)/documents/Locks/Lock_0"
FirebaseData firebaseData;
BluetoothSerial SerialBT;
TinyGPSPlus gps;
HTTPClient http;
DynamicJsonDocument doc(1024);
int lastState = 0;

void control_led(bool value) {
  if(value && lastState != 1) {
    Serial.println("Turned LED on.");
    digitalWrite(LED, HIGH); 
    lastState = 1;
  }
  else if(!value && lastState != 0) {
    Serial.println("Turned LED off.");
    digitalWrite(LED, LOW); 
    lastState = 0;
  }
}

void timeDate() {
  Serial.println(__DATE__);
  Serial.println(__TIME__);
}

void initWifi() {
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
}

int hash(String str) {
  if(str == "Locked") {
    return 1;
  }
  
}

void fireStoreGET(String url, String collection) {
  http.begin(url);
  int httpCode = http.GET();
  String payload = http.getString();
  deserializeJson(doc, payload);
  bool locked = false;
  switch(hash(collection)) {
    case 1:
      locked = doc["fields"][collection]["booleanValue"];
      break;
    default:
      Serial.println("Default, error in Firestore GET...");
  }
  control_led(locked);
}

void setup() {
  pinMode(LED, OUTPUT);
  Serial.begin(115200);
  Serial.println();
  timeDate();
  initWifi();
}

void loop() {
  fireStoreGET(String(FS_DATABASE_URL) + "Locks/" + "Lock_0/", "Locked");
  delay(5000);
}
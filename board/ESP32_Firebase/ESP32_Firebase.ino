#include <FirebaseESP32.h>
#include <Arduino.h>
#include "BluetoothSerial.h"
#include <TinyGPSPlus.h>
#include <HTTPClient.h>
#include <Arduino_JSON.h>
#define LED 2

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

#define WIFI_SSID "VODAFONE-B114"
#define WIFI_PASSWORD "tdE6KAtmqChRYgrX"

#define API_KEY "pzmetHjgzVn2I3lSQoevlBWGxZb7eR4h9dfVgGGi"
#define RT_DATABASE_URL "https://iot-bike-lock-default-rtdb.firebaseio.com/" 
#define FS_DATABASE_URL "https://firestore.googleapis.com/v1/projects/iot-bike-lock/databases/(default)/documents/Locks/Lock_0"
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

void realTime() {
  Firebase.begin("https://iot-bike-lock-default-rtdb.firebaseio.com/", "pzmetHjgzVn2I3lSQoevlBWGxZb7eR4h9dfVgGGi");
}

void firestore() {
  
}

void setup() {
  pinMode(LED, OUTPUT);
  Serial.begin(115200);
  Serial.println();
  timeDate();
  initWifi();
  realTime();
}

void loop() {
  control_led();
}
#include <FirebaseESP32.h>
#include <Arduino.h>
#include "BluetoothSerial.h"
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

void control_led() {
  if(Firebase.getBool(firebaseData, "/locks/lock0/locked")){
    bool locked = firebaseData.boolData();
    if(locked==true){ 
      digitalWrite(LED, HIGH); 
      Serial.println("Turned LED on.");
    }
    else { 
      digitalWrite(LED, LOW); 
      Serial.println("Turned LED off.");
    }
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
}

void loop() {
  control_led();
}
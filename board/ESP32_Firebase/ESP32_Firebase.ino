#include <FirebaseESP32.h>
#include "BLEDevice.h"
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>
#include <Arduino.h>
#define LED 2
// 1. Define the WiFi credentials */

// Liam's Wifi
#define WIFI_SSID "VODAFONE-B114"
#define WIFI_PASSWORD "tdE6KAtmqChRYgrX"

// TCD Wifi
// #define WIFI_SSID "TCD-Wifi"
// #define WIFI_PASSWORD "password?"

// For the following credentials, see examples/Authentications/SignInAsUser/EmailPassword/EmailPassword.ino

// 2. Define the API Key */
#define API_KEY "pzmetHjgzVn2I3lSQoevlBWGxZb7eR4h9dfVgGGi"

// 3. Define the RTDB URL */
#define DATABASE_URL "https://iot-bike-lock-default-rtdb.firebaseio.com/" //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app

// Define Firebase Data object
FirebaseData firebaseData;
FirebaseData RfirebaseData;

int r;
String knownBLEAddresses[] = {"55:c8:d4:47:ac:7c"};
bool device_found;
BLEScan* pBLEScan;

void control_led()
{
  // Check if lock is locked
  if(Firebase.getBool(firebaseData, "/locks/lock0/locked")){
    bool locked = firebaseData.boolData();
    // If lock is locked then turn on LED
    if(locked==true){
      digitalWrite(LED, HIGH);
    }
    // Else turn off LED
    else {
      digitalWrite(LED, LOW);
    }
  }
}

void setup()
{
  // Configure LED to OUTPUT
  pinMode(LED, OUTPUT);
  Serial.begin(115200);

  // Connect to wifi
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
  
  // Serial.println("Scanning...");
  // BLEDevice::init("");
  // pBLEScan = BLEDevice::getScan();
  // pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
  // pBLEScan->setActiveScan(true);
}

void loop()
{
  control_led();
  // BLEScanResults foundDevices = pBLEScan->start(30, false);
  // Serial.print(foundDevices.getCount());
  // for(int i = 0; i<foundDevices.getCount(); i++) {
  //   BLEAdvertisedDevice device = foundDevices.getDevice(i);
  //   int rssi = device.getRSSI();
  //   Serial.print("RSSI:");
  //   Serial.print(rssi);
  // }
  // pBLEScan->clearResults();
}
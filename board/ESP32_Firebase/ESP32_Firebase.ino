#include <FirebaseESP32.h>
#include "BLEDevice.h"
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>
#include <Arduino.h>
#include <WifiCredentials.h>
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
unsigned long duration = 0;
String knownBLEAddresses[] = {"55:c8:d4:47:ac:7c"};
bool device_found;
BLEScan* pBLEScan;

class MyAdvertisedDeviceCallbacks: public BLEAdvertisedDeviceCallbacks {
  void onResult(BLEAdvertisedDevice advertisedDevice) {
    for (int i = 0; i < (sizeof(knownBLEAddresses) / sizeof(knownBLEAddresses[0])); i++)
    {
      Serial.println(advertisedDevice.getAddress().toString().c_str());
      Serial.println(knownBLEAddresses[i].c_str());
      if (strcmp(advertisedDevice.getAddress().toString().c_str(), knownBLEAddresses[i].c_str()) == 0)
      {
        device_found = true;
        break;
      }
      else
        device_found = false;
    }
    Serial.printf("Advertised Device: %s \n", advertisedDevice.toString().c_str());
  }
};

void control_led()
{
  if(Firebase.getBool(firebaseData, "/locks/lock0/locked")){
    bool locked = firebaseData.boolData();
    if(locked==true){
      digitalWrite(LED, HIGH);
    }
    else {
      digitalWrite(LED, LOW);
    }
  }
}

void setup()
{
  pinMode(LED, OUTPUT);
  Serial.begin(115200);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  Firebase.begin("https://iot-bike-lock-default-rtdb.firebaseio.com/", "pzmetHjgzVn2I3lSQoevlBWGxZb7eR4h9dfVgGGi");
  duration = millis();
  
  Serial.println("Scanning...");
  BLEDevice::init("");
  pBLEScan = BLEDevice::getScan();
  pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
  pBLEScan->setActiveScan(true);
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
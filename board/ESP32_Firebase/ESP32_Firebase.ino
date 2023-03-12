#include <FirebaseESP32.h>
#include <Arduino.h>
#include "BluetoothSerial.h"
#include <TinyGPS.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <SoftwareSerial.h>
#include <WiFi.h>
#include "esp_wpa2.h"
#include "TinyGPS++.h"
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>
#include <BluetoothSerial.h>
#include "esp_bt_main.h"
#include "esp_bt_device.h"

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

#define WIFI_SSID "VODAFONE-B114"
#define WIFI_PASSWORD "tdE6KAtmqChRYgrX"

#define API_KEY "pzmetHjgzVn2I3lSQoevlBWGxZb7eR4h9dfVgGGi"
#define RT_DATABASE_URL "https://iot-bike-lock-default-rtdb.firebaseio.com/"
#define FS_DATABASE_URL "https://firestore.googleapis.com/v1/projects/iot-bike-lock/databases/(default)/documents/"

#define LED 2
#define SERVICE_UUID "4fafc201-afb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-37e1-4688-b7f5-ea07361b26a8"
FirebaseData firebaseData;
BluetoothSerial SerialBT;
SoftwareSerial serial_connection(12, 13);
TinyGPSPlus gps;
HTTPClient http;
DynamicJsonDocument doc(1024);
int lastState = 0;
int scanTime = 5;
BLEScan *pBLEScan;

void control_led(bool value)
{
  if (value && lastState != 1)
  {
    Serial.println("Turned LED on.");
    digitalWrite(LED, HIGH);
    lastState = 1;
  }
  else if (!value && lastState != 0)
  {
    Serial.println("Turned LED off.");
    digitalWrite(LED, LOW);
    lastState = 0;
  }
}

void timeDate()
{
  Serial.println(__DATE__);
  Serial.println(__TIME__);
}

void initWifi()
{
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

int hash(String str)
{
  if (str == "Locked")
  {
    return 1;
  }
}

void fireStoreGET(String url, String collection)
{
  http.begin(url);
  int httpCode = http.GET();
  String payload = http.getString();
  deserializeJson(doc, payload);
  bool locked = false;
  switch (hash(collection))
  {
  case 1:
    locked = doc["fields"][collection]["booleanValue"];
    break;
  default:
    Serial.println("Default, error in Firestore GET...");
  }
  control_led(locked);
}

class MyAdvertisedDeviceCallbacks : public BLEAdvertisedDeviceCallbacks
{
  void onResult(BLEAdvertisedDevice advertisedDevice)
  {
    Serial.print("Advertised Device: ");
    Serial.print(advertisedDevice.getAddress().toString().c_str());
    Serial.print(" ");
    if (advertisedDevice.haveName())
    {
      Serial.print("Name: ");
      Serial.print(advertisedDevice.getName().c_str());
    }
    Serial.print(", RSSI: ");
    Serial.println(advertisedDevice.getRSSI());
  }
};

void setup()
{
  pinMode(LED, OUTPUT);
  Serial.begin(115200);
  timeDate();
  initWifi();
  Serial.println("Scanning...");
  BLEDevice::init("MyESP32");
  BLEServer *pServer = BLEDevice::createServer();
  BLEService *pService = pServer->createService(SERVICE_UUID);
  BLECharacteristic *pCharacteristic = pService->createCharacteristic(CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE);
  pCharacteristic->setValue("Hello World says Liam");
  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();

}

void loop()
{
  fireStoreGET(String(FS_DATABASE_URL) + "Locks/" + "Lock_0/", "Locked");
  
  delay(2000);
}
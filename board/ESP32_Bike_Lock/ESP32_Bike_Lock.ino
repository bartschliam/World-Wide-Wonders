#include <FirebaseESP32.h>
#include <Arduino.h>
#include "BluetoothSerial.h"
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <SoftwareSerial.h>
#include <WiFi.h>
#include "esp_wpa2.h"
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>
#include <BluetoothSerial.h>
#include "esp_bt_main.h"
#include "esp_bt_device.h"
#include <string>
#include <ESP32Servo.h>
#include "TinyGPS++.h"

#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

#define WIFI_SSID "Wifi_name"
#define WIFI_PASSWORD "Wifi_password"

#define API_KEY "pzmetHjgzVn2I3lSQoevlBWGxZb7eR4h9dfVgGGi"
#define RT_DATABASE_URL "https://iot-bike-lock-default-rtdb.firebaseio.com/"
#define FS_DATABASE_URL "https://firestore.googleapis.com/v1/projects/iot-bike-lock/databases/(default)/documents/"

#define LED 2
#define SERVO_PIN  12
#define SERVICE_UUID "4fafc201-afb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-37e1-4688-b7f5-ea07361b26a8"

Servo myServo;
FirebaseData firebaseData;
BluetoothSerial SerialBT;
HTTPClient http;
DynamicJsonDocument doc(1024);
String lastState = "off";
SoftwareSerial serial_connection(25, 26);
TinyGPSPlus gps;

int scanTime = 5;
bool locked = false;
bool deviceConnected = false;
bool stolen = false;
BLEServer *pServer;

void control_led(bool value)
{
  if (value && lastState != "on")
  {
    Serial.println("Bike is locked.");
    myServo.write(0);
    digitalWrite(LED, HIGH);
    lastState = "on";
  }
  else if (!value && lastState != "off")
  {
    Serial.println("Bike is unlocked.");
    myServo.write(180);
    digitalWrite(LED, LOW);
    lastState = "off";
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
  else {
    return 0;
  }
}

void fireStoreGET(String url, String collection)
{
  http.begin(url);
  int httpCode = http.GET();
  if(httpCode == 200) {
    String payload = http.getString();
    deserializeJson(doc, payload);
    locked = doc["fields"][collection]["booleanValue"];
    control_led(locked);
  }
}

void fireStorePatchBool(String url, String item, bool stolen) {
  http.begin(url);
  int httpCode = http.GET();
  String payload = http.getString();
  deserializeJson(doc, payload);
  doc["fields"][item]["booleanValue"] = stolen;
  String updated;
  serializeJson(doc, updated);
  http.addHeader("Content-Type", "application/json");
  int response = http.PATCH(updated);
}

void fireStorePatchCoord(String url, String item, double lat, double lng) {
  http.begin(url);
  int httpCode = http.GET();
  String payload = http.getString();
  deserializeJson(doc, payload);
  doc["fields"][item]["geoPointValue"]["latitude"] = lat;
  doc["fields"][item]["geoPointValue"]["longitude"] = lng;
  String updated;
  serializeJson(doc, updated);
  http.addHeader("Content-Type", "application/json");
  int response = http.PATCH(updated);
}

class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    std::string value = pCharacteristic->getValue();
    Serial.print("Received value: ");
    for(int i=0; i<value.length(); i++) {
      Serial.print(value[i]);
    }
  }
};

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
    stolen = false;
    Serial.println("Device connected...");
    fireStorePatchBool(String(FS_DATABASE_URL) + "Locks/" + "Lock_0/", "Stolen", false);
  };
  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
    Serial.println("Device disconnected");
    if(locked) {
      Serial.println("Bike stolen");
      stolen = true;
    }
    BLEDevice::stopAdvertising();
    //BLEDevice::startAdvertising();
  };
};

void setupBLE() {
  BLEDevice::init("ESP32 Bike Lock 0");
  pServer = BLEDevice::createServer();
  BLEService *pService = pServer->createService(SERVICE_UUID);
  BLECharacteristic *pCharacteristic = pService->createCharacteristic(CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY);
  pCharacteristic->setValue("I'm the bike lock");
  pCharacteristic->setCallbacks(new MyCallbacks());
  pServer->setCallbacks(new MyServerCallbacks);
  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  Serial.println("BLE Setup finished");
}

void setup()
{
  pinMode(LED, OUTPUT);
  Serial.begin(9600);
  timeDate();
  initWifi();
  setupBLE();
  myServo.attach(SERVO_PIN);
  serial_connection.begin(9600);
  Serial.println("GPS Start");
}

void loop()
{
  fireStoreGET(String(FS_DATABASE_URL) + "Locks/" + "Lock_0/", "Locked");
  if(stolen) {
    fireStorePatchBool(String(FS_DATABASE_URL) + "Locks/" + "Lock_0/", "Stolen", true);
  }
  while(serial_connection.available() > 0) {
    gps.encode(serial_connection.read());
  }
  if(gps.location.isUpdated()) {
    Serial.print("Latitude: "); Serial.println(gps.location.lat(), 6);
    Serial.print("Longitude: "); Serial.println(gps.location.lng(), 6);
    fireStorePatchCoord(String(FS_DATABASE_URL) + "Locks/" + "Lock_0/", "Coords", gps.location.lat(), gps.location.lng());
    Serial.println("");
  }
  delay(2000);
}
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEScan.h>
#include <BLEAdvertisedDevice.h>

#define DEVICE_NAME "ESP32 Bike Lock 0"
#define SERVICE_UUID "4fafc201-afb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-37e1-4688-b7f5-ea07361b26a8"

BLEScan* pBLEScan;
BLEClient* pClient;
BLEAddress targetAddress("00:00:00:00:00:00");
bool connected = false;


class MyAdvertisedDeviceCallbacks: public BLEAdvertisedDeviceCallbacks {
    void onResult(BLEAdvertisedDevice advertisedDevice) {
      if(advertisedDevice.getName() == "ESP32 Bike Lock 0") {
        Serial.print("Found Device: ");
        Serial.println(advertisedDevice.toString().c_str());
      }
    }
};

class MyClientCallback: public BLEClientCallbacks {
  void onConnect(BLEClient* pclient) {
    Serial.println("Connected to ESP32 Bike Lock 0");
    connected = true;
  }

  void onDisconnect(BLEClient* pclient) {
    Serial.println("Disconnected from ESP32 Bike Lock!");
    connected = false;
  }
};

void setup() {
  Serial.begin(115200);
  BLEDevice::init("ESP32 Bike 0");
}

void loop() {
  if(!connected) {
    BLEScan* pBLEScan = BLEDevice::getScan();
    pBLEScan->setAdvertisedDeviceCallbacks(new MyAdvertisedDeviceCallbacks());
    pBLEScan->setActiveScan(true);
    BLEScanResults scanResults = pBLEScan->start(5);
    for(int i=0; i<scanResults.getCount(); i++) {
      BLEAdvertisedDevice device = scanResults.getDevice(i);
      if(device.getName() == "ESP32 Bike Lock 0") {
        pClient = BLEDevice::createClient();
        pClient->setClientCallbacks(new MyClientCallback());
        pClient->connect(device.getAddress());
      }
    }
  }
  delay(1000);
}
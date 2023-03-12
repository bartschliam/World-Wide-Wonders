#include <BluetoothSerial.h>
#include "esp_bt_main.h"
#include "esp_bt_device.h"


#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif

BluetoothSerial SerialBT;

void printAddress() {
  const uint8_t* point = esp_bt_dev_get_address();
  for(int i=0; i<6; i++) {
    char str[3];
    sprintf(str, "%02X", (int)point[i]);
    Serial.print(str);
    if(i<5) {
      Serial.print(":");
    }
  }
}

void setup()
{
  Serial.begin(115200);
  SerialBT.begin("ESP32test");
  Serial.println("Device started");
}

void loop()
{
  if(!SerialBT.connected()) {
    Serial.println("Not Connected");
    //SerialBT.connect("44:17:93:5E:2B:82");
  }
  else {
    Serial.println("Connected");
    printAddress();

  }
  delay(1000);
}
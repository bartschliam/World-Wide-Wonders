#include <FirebaseESP32.h>
#include <Arduino.h>
#define LED 2

#define WIFI_SSID "VODAFONE-B114"
#define WIFI_PASSWORD "tdE6KAtmqChRYgrX"

// TCD Wifi
// #define WIFI_SSID "TCD-Wifi"
// #define WIFI_PASSWORD "password?"
#define API_KEY "pzmetHjgzVn2I3lSQoevlBWGxZb7eR4h9dfVgGGi"
#define DATABASE_URL "https://iot-bike-lock-default-rtdb.firebaseio.com/" //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app

FirebaseData firebaseData;
char cr[] = __DATE__;
char ct[] = __TIME__;

void control_led() {
  if(Firebase.getBool(firebaseData, "/locks/lock0/locked")){
    bool locked = firebaseData.boolData();
    if(locked==true){ digitalWrite(LED, HIGH); }
    else { digitalWrite(LED, LOW); }
  }
}

void setup() {
  pinMode(LED, OUTPUT);
  Serial.begin(115200);
  Serial.print(cr, ct);
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
  
}

void loop() {
  control_led();
}
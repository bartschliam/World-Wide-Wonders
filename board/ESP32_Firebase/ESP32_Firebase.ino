#include <FirebaseESP32.h>
#define LED 2
// 1. Define the WiFi credentials */
#define WIFI_SSID "VODAFONE-B114"
#define WIFI_PASSWORD "tdE6KAtmqChRYgrX"

// For the following credentials, see examples/Authentications/SignInAsUser/EmailPassword/EmailPassword.ino

// 2. Define the API Key */
#define API_KEY "pzmetHjgzVn2I3lSQoevlBWGxZb7eR4h9dfVgGGi"

// 3. Define the RTDB URL */
#define DATABASE_URL "https://iot-bike-lock-default-rtdb.firebaseio.com/" //<databaseName>.firebaseio.com or <databaseName>.<region>.firebasedatabase.app

// 4. Define the user Email and password that alreadey registerd or added in your project */
#define USER_EMAIL "bartschliam@gmail.com"
#define USER_PASSWORD "ce75314d8e2"

// Define Firebase Data object
FirebaseData firebaseData;
FirebaseData RfirebaseData;

int r;
unsigned long duration = 0;

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
  
}

void loop()
{
  control_led();
  
}
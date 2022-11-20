//#include <AsyncTCP.h>
//#include <AsyncMqttClient.h>
#include "secrets.h"

extern "C" {
  #include "freertos/FreeRTOS.h"
  #include "freertos/timers.h"
}
#include <Wire.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include "WiFi.h"
#include <Adafruit_BME280.h>

Adafruit_BME280 bme;
float h,T;

#define AWS_IOT_PUBLISH_TOPIC "esp32/pub"
#define AWS_IOT_SUBSCRIBE_TOPIC "esp32/sub"

WiFiClient wifiClient;

void setup() {
  Serial.begin(115200);
  connectWiFi();
  connectAWS();

  if(!bme.begin(0x76))
  {
    Serial.print("Nie można wykryć sensora!!");
    delay(10000);
  }
}

void loop() {
  // put your main code here, to run repeatedly:
  h = bme.readHumidity();
  T = bme.readTemperature();


  if (isnan(h) || isnan(T)) {  // Check if any reads failed and exit early (to try again)
    Serial.println(F("Failed to read from BME sensor!"));
    return;
  }

  Serial.print(F("Humidity: "));
  Serial.print(h);
  Serial.print(F("%  Temperature: "));
  Serial.print(T);
  Serial.println(F("*C "));

  //publishMessage();
  //client.loop();
  delay(1000);
}




void messageHandler(char* topic, byte* payload, unsigned int length) {
  Serial.print("incoming: ");
  Serial.println(topic);

  StaticJsonDocument<200> doc;
  deserializeJson(doc, payload);
  const char* message = doc["message"];
  Serial.println(message);
}


void connectWiFi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  Serial.print("Connecting to Wi-Fi: ");
  Serial.println(WIFI_SSID);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.print("Connected to Wi-fi: ");
  Serial.println(WIFI_SSID);
}


void connectAWS() {
  /*
  // Configure WiFiClientSecure to use the AWS IoT device credentials
  net.setCACert(AWS_CERT_CA);
  net.setCertificate(CLIENT_CERT);
  net.setPrivateKey(PRIV_KEY);

  // Connect to the MQTT broker on the AWS endpoint we defined earlier
  client.setServer(MQTT_HOST, 8883);

  // Create a message handler
  client.setCallback(messageHandler);

  Serial.println("Connecting to AWS IoT");

  while (!client.connect(THING_NAME)) {
    Serial.print(".");
    delay(500);
  }

  if (!client.connected()) {
    Serial.println("AWS IoT Timeout!");
    return;
  }

  // Subscribe to a topic
  client.subscribe(AWS_IOT_SUBSCRIBE_TOPIC);

  Serial.println("AWS IoT Connected!");
  */
}


void publishMessage() {
  StaticJsonDocument<200> doc;
  doc["humidity"] = h;
  doc["temperature"] = T;
  char jsonBuffer[512];
  serializeJson(doc, jsonBuffer); // print to client

  //client.publish(AWS_IOT_PUBLISH_TOPIC, jsonBuffer)
}
































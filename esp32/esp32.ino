#include <WiFiClientSecure.h>

const char* ssid = "UPC662D292";
const char* password = "wmkn5xfzTxUu";

WiFiClient wifiClient;

void setup() {
  Serial.begin(115200); delay(50); Serial.println();
  Serial.println("ESP32 HTTP example");
  Serial.printf("SDK version: %s\n", ESP.getSdkVersion());

  Serial.print("Connecting to "); Serial.print(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.print(", WiFi connected, IP address: "); Serial.println(WiFi.localIP());
}

void loop() {
  // put your main code here, to run repeatedly:

}

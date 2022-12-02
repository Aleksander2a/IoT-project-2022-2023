#include <WiFi.h>
//#include <MQTTClient.h>
//#include "secrets.h"
extern "C" {
  #include "freertos/FreeRTOS.h"
  #include "freertos/timers.h"
}
#include <Wire.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <Adafruit_BME280.h>

Adafruit_BME280 bme;
float h,T;

#define AWS_IOT_PUBLISH_TOPIC "esp32/pub"
#define AWS_IOT_SUBSCRIBE_TOPIC "esp32/sub"

WiFiClient wifiClient;
WiFiClientSecure net;
//MQTTClient clientMQTT{256};


const char* ssidAP     = "ESP32-Access-Point";
const char* passwordAP = "IOTagh-2022";

String ssidWiFi     = "";
String passwordWiFi = "";

WiFiServer server(80);

String header;

void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_AP);
  makeAccessPoint();
  if(!bme.begin(0x76))
  {
    Serial.print("Nie można wykryć sensora!!");
    delay(10000);
  }
}

void loop(){
  // put your main code here, to run repeatedly:
  connectToWiFiUsingAP();
  if(WiFi.status() != WL_CONNECTED)return;
  connectAWS();
  
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
void makeAccessPoint(){
  Serial.println("Setting AP (Access Point)...");
  WiFi.softAP(ssidAP, passwordAP);

  IPAddress IP = WiFi.softAPIP();
  Serial.print("AP IP address: ");
  Serial.println(IP);
  
  server.begin();
}
void responseToGET(WiFiClient client){
  client.println("HTTP/1.1 200 OK");
  client.println("Content-type:text/html");
  client.println("Connection: close");
  client.println();
  client.println("<!DOCTYPE html>");
  client.println("<html lang=\"en\">");
  client.println("<head>");
  client.println("<meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge,chrome=1\">");
  client.println("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">");
  client.println("<meta charset=\"UTF-8\">");
  client.println("<title>ESP32 Config</title>");
  client.println("<style>");
  client.println("body{display: flex;align-items: center;justify-content: center;flex-direction: column;}");
  client.println("</style>");
  client.println("</head>");
  client.println("<body>");
  client.println("<h2>Konfiguracja połączenia urządzenia z routerem WiFi</h2>");
  client.println("<p>Podaj dane sieci, do której chcesz podłączyć urządzenie. Po zatwierdzeniu danych, połączenie z "+String(ssidAP)+" urwie się. Jeśli dane będą poprawne, sieć "+String(ssidAP)+" przestanie być widoczna, w innym przypadku należy ponownie połączyć się z "+String(ssidAP)+" i podać dane.</p>");
  client.println("<form method=\"post\">");
  client.println("<label for=\"ssid\">SSID:</label><br>");
  client.println("<input type=\"text\" id=\"ssid\" name=\"ssid\" required><br>");
  client.println("<label for=\"pwd\">Hasło:</label><br>");
  client.println("<input type=\"password\" id=\"pwd\" name=\"pwd\" ><br><br>");
  client.println("<input type=\"submit\" value=\"Zaakceptuj\">");
  client.println("</form>");
  client.println("</body>");
  client.println("</html>");
  client.println();
}
void responseToPOST(WiFiClient client){
  WiFi.mode(WIFI_AP_STA);
  getSsidAndPassword(header);
  Serial.print("Connecting to "); Serial.print(ssidWiFi);
  if(passwordWiFi=="")WiFi.begin(ssidWiFi.c_str());
  else WiFi.begin(ssidWiFi.c_str(), passwordWiFi.c_str());
  int r=0; //retry counter
  while (WiFi.status() != WL_CONNECTED && r<10) {
    delay(500);
    Serial.print(".");
    r++;
    }
    if(r==10){
      Serial.println("Connection failed");;
      ESP.restart();
    }  
    else{
      Serial.println("WiFi connected, IP address: ");
      WiFi.mode(WIFI_STA);
    }
}
void getSsidAndPassword(String header){
  header+='\n';
  int last_nl = header.lastIndexOf('\n');
  int last_but1_nl=header.substring(0, last_nl).lastIndexOf('\n');
  String payload = header.substring(last_but1_nl+1, last_nl);
  int appersantidx = payload.indexOf('&');
  String ssidPart = payload.substring(0,appersantidx);
  int eqidx = ssidPart.indexOf('=');
  ssidWiFi = ssidPart.substring(eqidx+1);
  String pwdPart = payload.substring(appersantidx+1);
  eqidx = pwdPart.indexOf('=');
  passwordWiFi = pwdPart.substring(eqidx+1); 
}
int getContentLength(String header){
  String cl_str = "Content-Length: ";
  int cl_index=header.indexOf(cl_str);
  char cl_first_digit = header[cl_index + cl_str.length()];
  String cl_number_str="";
  cl_number_str+=cl_first_digit;
  while(header[++cl_index + cl_str.length()]!='\n')cl_number_str+=header[cl_index + cl_str.length()];
  return cl_number_str.toInt();
}
void connectToWiFiUsingAP(){
  WiFiClient client = server.available();

  if (client) {                             
    Serial.println("New Client.");          
    String currentLine = "";               
    int POSTcont_len=0;
    bool POSTpayload = false;
    while (client.connected()) {          
      if (client.available()) {         
        char c = client.read();            
        Serial.write(c);                
        header += c;
        if(POSTcont_len!=0)POSTcont_len--;
        if (c == '\n' && header[0]=='G'){
          if (currentLine.length() == 0) {
            responseToGET(client);
            break;
          } else {
            currentLine = "";
          }          
        }
        else if (c == '\n' && header[0]=='P' && !POSTpayload) {
          if (currentLine.length() == 0) {
            POSTpayload = true;
            POSTcont_len = getContentLength(header);
            
          } else {
            currentLine = "";
          }
        }
        else if (POSTcont_len==0 && header[0]=='P' && POSTpayload) {
          responseToPOST(client);
          break;
        } else if (c != '\r') {
          currentLine += c;
        }
      }
    }
    // Clear the header variable
    header = "";
    // Close the connection
    client.stop();
    Serial.println("Client disconnected.");
    Serial.println("");
  }
}
void messageHandler(char* topic, byte* payload, unsigned int length) {
  Serial.print("incoming: ");
  Serial.println(topic);

  StaticJsonDocument<200> doc;
  deserializeJson(doc, payload);
  const char* message = doc["message"];
  Serial.println(message);
}
void connectAWS() {
  /*
  // Configure WiFiClientSecure to use the AWS IoT device credentials
  net.setCACert(AWS_CERT_CA);
  net.setCertificate(CLIENT_CERT);
  net.setPrivateKey(PRIV_KEY);
  // Connect to the MQTT broker on the AWS endpoint we defined earlier
  //client.setServer(MQTT_HOST, 8883);
  client.begin(AWS_IOT_ENDPOINT, 8883, net);
  // Create a message handler
  //client.setCallback(messageHandler);
  client.onMessage(messageHandler);
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

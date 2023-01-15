#include <WiFi.h>
#include <Wire.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <cstring>
#include <Adafruit_BME280.h>
extern "C" {
  #include "freertos/FreeRTOS.h"
  #include "freertos/timers.h"
}
#include <Crypto.h>
#include <Arduino.h>

#define THING_NAME "esp32"
#define AWS_HOST "a2m6jezl11qjqa-ats.iot.eu-west-1.amazonaws.com"

WiFiClient wifiClient;
WiFiClientSecure net;

Adafruit_BME280 bme;
float h,T,p;

const char* ssidAP     = "ESP32-Access-Point";
const char* passwordAP = "IOTagh-2022";

String ssidWiFi     = "";
String passwordWiFi = "";

WiFiServer server(80);

String header;

const char* certificate_pem_crt = R"EOF(
-----BEGIN CERTIFICATE-----
MIIDWjCCAkKgAwIBAgIVAOZoZlfzRrjxCU9tXJxPmE5liK0LMA0GCSqGSIb3DQEB
CwUAME0xSzBJBgNVBAsMQkFtYXpvbiBXZWIgU2VydmljZXMgTz1BbWF6b24uY29t
IEluYy4gTD1TZWF0dGxlIFNUPVdhc2hpbmd0b24gQz1VUzAeFw0yMjExMTgxNjU4
NDZaFw00OTEyMzEyMzU5NTlaMB4xHDAaBgNVBAMME0FXUyBJb1QgQ2VydGlmaWNh
dGUwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDTPKX2OXrKJy4Ma3KT
N98ej27Mb4XAosqGiy39+CjblV+Ip9ixS2mVuZEZDv8/Tu32LDBirIDkrKfCpD++
W0SCI24x0igTkHWeIBuQRJRITMtqI4bQPxQcQBTRk8AEMiK3ICV4IqcrB4BPeA47
fk56pqofy2fVHxEgmPjFBqrdgyKMyTXMjxtnAkN5l1BK0WJ6U1EZm05oANOABSJD
mE1K/zr2eszKwjSpo2f3Em8bEmeAahOOjbW56jWRKSmq7pA1YFCwYsTfeD1ZA4lr
B/9NGESwJtDIaDsUNEs7W60AQ58BLhIqJ5bliWSqSPIc+sC6zPVnwqnR/jJ6qLnD
ajGjAgMBAAGjYDBeMB8GA1UdIwQYMBaAFMqajCLMbCckWDLOjzeGKXzS6lJQMB0G
A1UdDgQWBBQSoJCVvZliJWaFciICKqCRcLdJjDAMBgNVHRMBAf8EAjAAMA4GA1Ud
DwEB/wQEAwIHgDANBgkqhkiG9w0BAQsFAAOCAQEAjuNPcTFlQj6Le7nkf7Q3gJSl
xJptYr+zi/x7kQsAuTcKH0jU8s3/WD3PTdIzxD63DWWYBCtZaSs0dWogdo/PFMgA
lNeR5HPTWrqnl2hOXs51qp7KWvFeKlbHqKfoInJLj4SMyGODmuNgS0LYIzCAGXBI
D5VRfxy+eJt/ZheNxPIefpyET0DcxDuzuSXylxz3WOSGfrUPulEGewmmG5XzpwzZ
48Z+E6hPdFfR64hl9RCWvrCgxwWizPI1tftrtHOCn4zVfmpX5NCGOQKO7wh2/Gcz
oIDqmy2ogPwLlKGXMS7U3XX/eoCDA6fNkdQAiVbv1ASDSu6pTi/2PFtIMaxiOQ==
-----END CERTIFICATE-----
)EOF";

const char* rootCA = R"EOF(
-----BEGIN CERTIFICATE-----
MIIDQTCCAimgAwIBAgITBmyfz5m/jAo54vB4ikPmljZbyjANBgkqhkiG9w0BAQsF
ADA5MQswCQYDVQQGEwJVUzEPMA0GA1UEChMGQW1hem9uMRkwFwYDVQQDExBBbWF6
b24gUm9vdCBDQSAxMB4XDTE1MDUyNjAwMDAwMFoXDTM4MDExNzAwMDAwMFowOTEL
MAkGA1UEBhMCVVMxDzANBgNVBAoTBkFtYXpvbjEZMBcGA1UEAxMQQW1hem9uIFJv
b3QgQ0EgMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALJ4gHHKeNXj
ca9HgFB0fW7Y14h29Jlo91ghYPl0hAEvrAIthtOgQ3pOsqTQNroBvo3bSMgHFzZM
9O6II8c+6zf1tRn4SWiw3te5djgdYZ6k/oI2peVKVuRF4fn9tBb6dNqcmzU5L/qw
IFAGbHrQgLKm+a/sRxmPUDgH3KKHOVj4utWp+UhnMJbulHheb4mjUcAwhmahRWa6
VOujw5H5SNz/0egwLX0tdHA114gk957EWW67c4cX8jJGKLhD+rcdqsq08p8kDi1L
93FcXmn/6pUCyziKrlA4b9v7LWIbxcceVOF34GfID5yHI9Y/QCB/IIDEgEw+OyQm
jgSubJrIqg0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMC
AYYwHQYDVR0OBBYEFIQYzIU07LwMlJQuCFmcx7IQTgoIMA0GCSqGSIb3DQEBCwUA
A4IBAQCY8jdaQZChGsV2USggNiMOruYou6r4lK5IpDB/G/wkjUu0yKGX9rbxenDI
U5PMCCjjmCXPI6T53iHTfIUJrU6adTrCC2qJeHZERxhlbI1Bjjt/msv0tadQ1wUs
N+gDS63pYaACbvXy8MWy7Vu33PqUXHeeE6V/Uq2V8viTO96LXFvKWlJbYK8U90vv
o/ufQJVtMVT8QtPHRh8jrdkPSHCa2XV4cdFyQzR1bldZwgJcJmApzyMZFo6IQ6XU
5MsI+yMRQ+hDKXJioaldXgjUkK642M4UwtBV8ob2xJNDd2ZhwLnoQdeXeGADbkpy
rqXRfboQnoZsG4q5WTP468SQvvG5
-----END CERTIFICATE-----
)EOF";

const char* private_pem_key = R"EOF(
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA0zyl9jl6yicuDGtykzffHo9uzG+FwKLKhost/fgo25VfiKfY
sUtplbmRGQ7/P07t9iwwYqyA5KynwqQ/vltEgiNuMdIoE5B1niAbkESUSEzLaiOG
0D8UHEAU0ZPABDIityAleCKnKweAT3gOO35OeqaqH8tn1R8RIJj4xQaq3YMijMk1
zI8bZwJDeZdQStFielNRGZtOaADTgAUiQ5hNSv869nrMysI0qaNn9xJvGxJngGoT
jo21ueo1kSkpqu6QNWBQsGLE33g9WQOJawf/TRhEsCbQyGg7FDRLO1utAEOfAS4S
KieW5YlkqkjyHPrAusz1Z8Kp0f4yeqi5w2oxowIDAQABAoIBAAzYJjtHmXjLUxh8
PBZJkm6YSCN0MIzbGTd/JQfJXCql9Y4orptxO3VYOENuzwR5dyy92R9W3+uHuBe0
xw97GzpSjzPGVJuD8DLyPtrR4LZYvRGyIVNuUnm5R8rKkiVvKv85nC2m5cVPCnVK
lor1ji4VDkkqpCCoZ/E0fAP2+NLJNygPp9BEq8SgDVAag9JxRZkvxSolSi5fjafd
HjQXV7SsTX40WXncFLJBc/88Dt3JgM0Vps1hELdIrt+V9iQFOr6/sdC6aGW+A+i5
7gpUNGhEsgzTu0hZzci59XKdPqmyOeUx5ELIx1sAzyfn3aPVFNhW6Qn5N7KEziHX
hF4dqYECgYEA+mOObsUXf75VsVlMbNYoxNfrkiq+gvYIkWrH+0/M2+eeECucU9fI
S/lo+4lO332TEd+8WFksuQHYHJbKHr/4p6tQBIXHRtl8XdCKjiqzKUxHXXSr7KRs
TJDW8Nen5O++u3OlRiNzflV0mTrb3D4xUdU94mtqK2jmI8l7JlTSJMECgYEA1/h7
msWnRb/w3OR+zMgJjXsAfPaKzWThtS0Fxa2bygol/Zk4jwjYuZQEUQSZF12/JvN0
wcJU99B049VhDTtNWvQpULNMNf/rMWSCDe3EHj5qnHyR8lUfcsBIFAJEwWMj2Nyg
7BpsRADxIXjePisv6wwef/Idac5encd9/feNu2MCgYAW4p6UFUOOk3D1ornPgMt9
IlcPpwR+p8oksGPS3npU5xiVVccWCrTt7L/hra0d1DZq/c4TLSNfTYHZKxcSNG2f
tZK8txV9rkcls/fWAqUZczVan11PZb/YR6y9mphn3lnKfElw3bCirWDY2H5b5PtR
BXKAjVzI1u+h+bpdyIbkgQKBgDTRlIk5pbstQh8D0u8KTSvI1Um6kh/BeGHy7OJ3
nw4+hSQMgQSaSUa5qISX90j7qHBCQl/Qwy8IUE4YNXAi/Lwt0pzl/NGIEWE3D4eQ
itJKuZAj9x2pK9PIqtgZ5e7V7EJxUvnrTGclQ9PH17KkpUd640qvT/o8em9kBrBC
Buu5AoGBAMTDVnT6PJLwpDBcZieoP+2Kg+DSr37FY65d2RRJAhdjd3d9ne61r26d
e12zlV3efhdRq5w2MhgWogK8SzAdAqte5rmzzW8aicPXfuS8SzZyb+7I358SAsRe
sFySluQqniBcLl163oVDu8VwQ+iMjV5CmX1hc9oHVMxKZhmntXYF
-----END RSA PRIVATE KEY-----
)EOF";


// ===================================================== RSA BEGIN =====================================================
/*
#include <RSA.h>

const char* app_public_key = R"EOF(
-----BEGIN PUBLIC KEY-----
MIGeMA0GCSqGSIb3DQEBAQUAA4GMADCBiAKBgG8B8gESsUV9lgbkjTl4zzs+UmiW
p71CWElQlrICW32JRAjqjSuwOYnjEwtJlExkDtywsyuzI+hZTqJkDuMBdygu6qaV
HhTXqy9ew/XommRYFR+nHpuJAC3cl2/rBcnJ6ybthFK2bXjwceEhiyGMNh57zOPV
P9FsLiQQggBRFF9zAgMBAAE=
-----END PUBLIC KEY-----
)EOF";

const char* esp_private_key = R"EOF(
-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQC8BZJdirXnN+CqOBGhlj54tc6hBXg5ty2KHlbm48NuoPupoU/M
8NqMoaj/CF7eLj1UHC7VoGPHZFpk4UbFNyq++rCvEW0ubk9ptf3wyZeUZfoQle+N
OIb0161t4vtuwRPUNrJIexXbnz8VOko9TIea2Zjkow8v9Guo1DpW3HMxuwIDAQAB
AoGAVp/yiSpJGFgEKChg5yODcLXClykf9OdSEdpci0/QUH3WtJZfX7pv1m78n1NJ
8e83zjKV2VJl5g10IBoyMtZx2HT4VKSCnd6dqOuyVz162ccXsY+zkX9XZCOteMM/
dh5/l7q/HxQ0D2YT4zMEOpx+YRkGWpD0fPL2dSibn4tZ1VECQQDjfxZCmWO3iepl
AuEH0ytZkY1l6M5c40kbn2QGPqfrA4MQ5TgUT5F/S+VYZQUIU2VlJUnGN5snZDya
TcUKivkdAkEA05RXQw6UHm8FP44fLB7u5AERsw+AjNl61qWQCXfVuYtjmBEujodz
QueG2OVke/M//YC3Vt9u48GkxNRNhps2twJBANeqlj7CzY6kt0nVReG2JkV+P87Z
ujDC437FRvzIj0WziaANvXE70VIdcCmxcujmrpwJknvQIU1hsDYT/fU1tF0CQGY3
rojZDDo/zLtNwEWilCtXUOO/Q43IrA3zYskQOhMwAme/NUzqp4bVMFKtUISJmoqw
muK/g2VJcn8dSm8TobUCQCF3LcJSt6QHC0K09LxK7izYDNqn0mpJkBwMBiSUZgEM
tJopM0QpJs46yR5eCoxsU+pUUxsROb7zhN9JbRdfB6U=
-----END RSA PRIVATE KEY-----
)EOF";


RSA decrypter;
RSA encrypter;

String decryptMessageRSA(const char* cipherText) {
  char plainText[256];
  decrypter.begin(RSA_PRIVATE, esp_private_key);
  int len = decrypter.privateDecrypt(cipherText, strlen(cipherText), plainText);
  plainText[len] = '\0';
  return String(plainText);
}

String encryptMessageRSA(const char* plainText) {
  char cipherText[256];
  encrypter.begin(RSA_PUBLIC, app_public_key);
  int len = encrypter.publicEncrypt(plainText, strlen(plainText), cipherText);
  cipherText[len] = '\0';
  return String(cipherText);
}
*/
// ===================================================== RSA END =====================================================

// ===================================================== AES BEGIN =====================================================
#include <AES.h>
#include <AESLib.h>

String key = "my 32 length key................";
String iv = "my 16 length iv!";

AES aes;

String decryptMessageAES(const char* ciphertext) {
  aes.set_key((byte*)key.c_str(), key.length());
  byte decrypted[strlen(ciphertext) / 2];
  aes.cbc_decrypt((byte*)ciphertext, decrypted, strlen(ciphertext) / 2, (byte*)iv.c_str());
  return (char*)decrypted;
}

String encryptMessageAES(const char* plaintext) {
  aes.set_key((byte*)key.c_str(), key.length());
  byte encrypted[strlen(plaintext)];
  aes.cbc_encrypt((byte*)plaintext, encrypted, strlen(plaintext), (byte*)iv.c_str());
  return String((char*)encrypted);
}
// ===================================================== AES END =====================================================

bool stopPublishing;

void msgReceived(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message received on ");
  Serial.print(topic);
  Serial.print(": ");
  char message[length];
  for (int i=0; i<length; i++) {
    Serial.print((char)payload[i]);
    message[i] = (char)payload[i];
  }
  Serial.println();

  // Parse message to JsonObject
  StaticJsonDocument<200> doc;
  DeserializationError error = deserializeJson(doc, message);
  const char* command = doc["Command"];
  command = decryptMessageAES(command).c_str();
  // Execute command in message
  Serial.print("Command to exetute is: "); Serial.println(command);
  if (strcmp(command, "Stop")==0) {
    Serial.println("Stopping the publishing of messages");
    stopPublishing = true;
  } else if(strcmp(command, "Resume")==0) {
    Serial.println("Resuming the publishing of messages");
    stopPublishing = false;
  }
}

PubSubClient pubSubClient(AWS_HOST, 8883, msgReceived, net);

// ===================================================== SETUP BEGIN =====================================================
void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_AP);
  makeAccessPoint();
  if(!bme.begin(0x76))
  {
    Serial.print("Can't detect sensor !!!");
    delay(10000);
  }

  // AWS
  net.setCACert(rootCA);
  net.setCertificate(certificate_pem_crt);
  net.setPrivateKey(private_pem_key);
  stopPublishing = false;

  // Display unique code
  Serial.print("Your ESP Board MAC Address is:  ");
  Serial.println(WiFi.macAddress());
}
// ===================================================== SETUP END =====================================================

// ===================================================== LOOP BEGIN =====================================================
void loop(){
  // Connect to WiFi
  connectToWiFiUsingAP();
  if(WiFi.status() != WL_CONNECTED)return;

  // AWS
  connectAWS();
  
  // Read sensor data
  h = bme.readHumidity();
  T = bme.readTemperature();
  p = bme.readPressure() / 100.0F; // result in hPa

  if (isnan(h) || isnan(T) || isnan(p)) {  // Check if any reads failed and exit early (to try again)
    Serial.println(F("Failed to read from BME sensor!"));
    return;
  }

  // AWS publish message
  char sensorData[128];
  sprintf(sensorData, "{\"Temperature\": %s, \"Humidity\": %s, \"Pressure\": %s}", encryptMessageAES(String(T).c_str()), encryptMessageAES(String(h).c_str()), encryptMessageAES(String(p).c_str()));
  if(stopPublishing==false) {
    boolean rc = pubSubClient.publish((WiFi.macAddress()+"/sensorData").c_str(), sensorData);
    Serial.print("Message published, rc="); Serial.print( (rc ? "OK: " : "FAILED: ") );
  }
  Serial.println(sensorData);

  delay(1000);
}
// ===================================================== LOOP END =====================================================

// ===================================================== ACCESS POINT BEGIN =====================================================
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
  client.println(encryptMessageAES(WiFi.macAddress().c_str()));
  client.println();
}
void responseToPOST(WiFiClient client){
  client.println("HTTP/1.1 200 OK");
  client.println("Content-type:text/html");
  client.println("Connection: close");
  client.println();

  WiFi.mode(WIFI_AP_STA);
  getSsidAndPassword(header);
  Serial.print(" Connecting to "); Serial.print(ssidWiFi);
  Serial.println("");
  Serial.print("Password: "); Serial.println(passwordWiFi);
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
  ssidWiFi = decryptMessageAES(ssidPart.substring(eqidx+1).c_str());
  String pwdPart = payload.substring(appersantidx+1);
  eqidx = pwdPart.indexOf('=');
  passwordWiFi = decryptMessageAES(pwdPart.substring(eqidx+1).c_str()); 
}
int getContentLength(String header){
  String cl_str = "content-length: ";
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
        } 
        else if (c != '\r') {
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
// ===================================================== ACCESS POINT END =====================================================

// ===================================================== AWS BEGIN =====================================================
void connectAWS() {
  if (!pubSubClient.connected()) {
    Serial.print("PubSubClient connecting to: "); Serial.print(AWS_HOST);
    while (!pubSubClient.connected()) {
      Serial.print(".");
      pubSubClient.connect(THING_NAME);
      delay(1000);
    }
    Serial.println(" connected");
  }
  pubSubClient.subscribe((WiFi.macAddress()+"/commands").c_str());
  pubSubClient.loop();
}
// ===================================================== AWS END =====================================================

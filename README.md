# IoT-project-2022-2023

## ESP32
### Requirements:
- [Arduino IDE](https://www.arduino.cc/en/software) (! WARNING ! - [Nightly build](https://www.arduino.cc/en/software#:~:text=newer%2C%2064%20bits-,Nightly%20Builds,-Download%20a%20preview) may be required in case of some errors with connecting board)
- ESP32-WROOM-DA Module

Useful article on connecting ESP32 board: [LINK](https://randomnerdtutorials.com/installing-the-esp32-board-in-arduino-ide-windows-instructions/)

## Mobile App
### Requirements:
- [Flutter](https://docs.flutter.dev/get-started/install)
- [Amplify](https://docs.amplify.aws/cli/start/install/)

## AWS
### PubSub topics:
#### esp32/pub
The board sends sensor data to this topic. Sample JSON:
```json
{
  "Temperature": 21.73,
  "Humidity": 52.763672
}
```

#### esp32/sub
The board reads commands that are sent to this topic. Allowed messages:
To stop sending sensor data to AWS
```json
{
  "Command": "Stop"
}
```
To resume sending sensor data to AWS
```json
{
  "Command": "Resume"
}
```
When the board is first run, it will send data to AWS by default

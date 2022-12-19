import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/src/widgets/automatic_keep_alive.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
// import 'package:amplify_api/amplify_api.dart'; // UNCOMMENT this line after backend is deployed

// Generated in previous step
import '../models/ModelProvider.dart';
import '../amplifyconfiguration.dart';
import '../models/Users.dart';
import '../models/Profiles.dart';

import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'dart:async';
import 'dart:convert';


class Measures extends StatefulWidget {
  Measures({Key? key, required this.user, required this.userProfiles, required this.activeProfile, required this.notifyParent}) : super(key: key);

  final Function() notifyParent;
  Users user;
  List<Profiles> userProfiles;
  Profiles activeProfile;

  @override
  State<Measures> createState() => _MeasuresState();
}

class _MeasuresState extends State<Measures>
    with AutomaticKeepAliveClientMixin {
  String dropdownValue = '';
  double temperature = 0;
  double humidity = 0;
  double pressure = 0;
  final MqttServerClient client = MqttServerClient("a2m6jezl11qjqa-ats.iot.eu-west-1.amazonaws.com", '');
  late StreamSubscription subscription;
  TextEditingController tempController = TextEditingController();
  TextEditingController humController = TextEditingController();
  TextEditingController presController = TextEditingController();


  Widget _activeProfileInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          'Aktywny profil: ' + widget.activeProfile.profile_name,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        )
      ],
    );
  }

  _connect() {

  }

  _disconnect() {

  }

  Future<bool> mqttConnect(String uniqueId) async {
    print("Connecting to MQTT");
    ByteData rootCA = await rootBundle.load('assets/certs/RootCA.pem');
    ByteData deviceCert = await rootBundle.load('assets/certs/DeviceCertificate.crt');
    ByteData privateKey = await rootBundle.load('assets/certs/Private.key');

    SecurityContext context = SecurityContext.defaultContext;
    context.setClientAuthoritiesBytes(rootCA.buffer.asUint8List());
    context.useCertificateChainBytes(deviceCert.buffer.asUint8List());
    context.usePrivateKeyBytes(privateKey.buffer.asUint8List());

    client.securityContext = context;
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.port = 8883;
    client.secure = true;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.pongCallback = pong;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(uniqueId)
        .startClean();
    client.connectionMessage = connMess;

    await client.connect();
    if (client != null && client.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected to AWS');
    } else {
      return false;
    }

    subscription = client.updates?.listen(_onMessage) as StreamSubscription;

    String topic = '${widget.user.device_id}/sensorData';
    client.subscribe(topic, MqttQos.atMostOnce);

    return true;
  }

  void _onMessage(List<mqtt.MqttReceivedMessage> event) {
    final mqtt.MqttPublishMessage recMess =
    event[0].payload as mqtt.MqttPublishMessage;
    final String message =
    mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    print('MQTT message: topic is <${event[0].topic}>, payload is <-- $message -->');
    Map valueMap = json.decode(message);
    temperature = valueMap['Temperature'].toDouble();
    humidity = valueMap['Humidity'].toDouble();
    pressure = valueMap['Pressure'].toDouble();
    // Round to 1 decimal places
    temperature = (temperature * 10).round() / 10;
    humidity = (humidity * 10).round() / 10;
    pressure = (pressure * 10).round() / 10;

    tempController.text = temperature.toString();
    humController.text = humidity.toString();
    presController.text = pressure.toString();
    print(temperature.toString());
    print(humidity.toString());
    print(pressure.toString());
  }

  void onConnected() {
    print("Connected to MQTT");
  }

  void onDisconnected() {
    print("Disconnected from MQTT");
  }

  void pong() {
    print("Pong");
  }

  void setMeassuerments(String uniqueId) async {

  }


  Widget _measurement(String title) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 100,
            height: 100,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.blue[100]),
            child: Center(
              child: TextField(
                controller: title == 'Temperatura'
                    ? tempController
                    : title == 'Wilgotność'
                        ? humController
                        : presController,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[900]),
            ),
              // child: Text("placeholder",
              //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          )
        ]);
  }

  Widget _data() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(height: 50),
          _measurement("Temperatura"),
          SizedBox(height: 50),
          _measurement("Wilgotność"),
          SizedBox(height: 50),
          _measurement("Ciśnienie"),
        ]);
  }

  Widget _button(String title) {
    return InkWell(
      onTap: () {
        if (title == 'Zatrzymaj') {
          // Publish mqtt message to stop
          final mqtt.MqttClientPayloadBuilder builder = mqtt.MqttClientPayloadBuilder();
          builder.addString('{"Command": "Stop"}');
          client.publishMessage('${widget.user.device_id}/commands', MqttQos.atMostOnce, builder.payload!);
        } else {
          // Publish mqtt message to resume
          final mqtt.MqttClientPayloadBuilder builder = mqtt.MqttClientPayloadBuilder();
          builder.addString('{"Command": "Resume"}');
          client.publishMessage('${widget.user.device_id}/commands', MqttQos.atMostOnce, builder.payload!);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width/3,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xff1c98ad), Color(0xff057ace)])),
        child: Text(
          title,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _functionButtons() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:<Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _button("Zatrzymaj"),
              ]
        ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _button("Wznów"),
              ]
          ),
        ],);
  }

  @override
  bool get wantKeepAlive => true;

  Widget _entryColumn(String title, String fieldFor1, String fieldFor2, String fieldFor3) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Text(title=='MIN' ? widget.activeProfile.min_temperature.toString() : widget.activeProfile.max_temperature.toString(),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            )
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Text(title=='MIN' ? widget.activeProfile.min_humidity.toString() : widget.activeProfile.max_humidity.toString(),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            )
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Text(title=='MIN' ? widget.activeProfile.min_pressure.toString() : widget.activeProfile.max_pressure.toString(),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            )
          ]),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    mqttConnect("uniqueID");
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
      height: height,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 50),
                  _activeProfileInfo(),
                  SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: 20),
                              Text(
                                "Temperatura",
                                style: TextStyle(fontSize: 15),
                              ),
                              SizedBox(height: 50),
                              Text(
                                "Wilgotność",
                                style: TextStyle(fontSize: 15),
                              ),
                              SizedBox(height: 50),
                              Text(
                                "Ciśnienie",
                                style: TextStyle(fontSize: 15),
                              ),
                            ]),
                        _entryColumn("MIN", "minTemp", "minHum", "minPres"),
                        _entryColumn("MAX", "maxTemp", "maxHum", "maxPres"),
                      ]),
                  SizedBox(height: 50),
                  _data(),
                  SizedBox(height: 50),
                  _functionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

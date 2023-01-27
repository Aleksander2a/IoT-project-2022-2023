import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/src/widgets/automatic_keep_alive.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// Generated in previous step
import '../models/ModelProvider.dart';
import '../models/Users.dart';
import '../models/Profiles.dart';

import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'dart:async';
import 'dart:convert';

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;



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
  num temperature = 0;
  num humidity = 0;
  num pressure = 0;

  final MqttServerClient client = MqttServerClient("a2m6jezl11qjqa-ats.iot.eu-west-1.amazonaws.com", '');
  TextEditingController tempController = TextEditingController();
  TextEditingController humController = TextEditingController();
  TextEditingController presController = TextEditingController();

  Timer? timer;

  @override
  void initState() {
    super.initState();
    mqttConnect(Uuid().v4());
    fetchSensorData();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => fetchSensorData());
  }

  Future<void> fetchSensorData() async {
    // Get sensor data from API
    String uri = 'https://km2lp7sn27.execute-api.eu-west-1.amazonaws.com/betae/sensordata?device_id=${widget.user.device_id}';
    print("URI: $uri");
    print("Before calling API");
    var response = await http.get(
        Uri.parse(uri),
        headers: {"x-api-key": "b0zk8nTWwj5E63DstZlBXa2xstTKArlv4nYjjvfS"}
    );
    print(response.body);
    print("After calling API");
    var data = jsonDecode(response.body);
    if(data[0] == null) {
      return;
    }
    data = data[0];
    if (data['device_id'] != widget.user.device_id) {
      print("Wrong device");
      return;
    }
    setState(() {
      temperature = data['temperature'];
      humidity = data['humidity'];
      pressure = data['pressure'];

      // Round to 1 decimal places
      temperature = (temperature * 10).round() / 10;
      humidity = (humidity * 10).round() / 10;
      pressure = (pressure * 10).round() / 10;

      tempController.text = temperature.toString();
      humController.text = humidity.toString();
      presController.text = pressure.toString();
    });
    print("Temperature: $temperature");
    print("Humidity: $humidity");
    print("Pressure: $pressure");
  }

  Color isTempOk() {
    if (tempController.text == '') {
      return Colors.green;
    }
    if (double.parse(tempController.text) < widget.activeProfile.min_temperature! || double.parse(tempController.text) > widget.activeProfile.max_temperature!) {
      return Colors.red;
    }
    return Colors.green;
  }

  Color isHumOk() {
    if (humController.text == '') {
      return Colors.green;
    }
    if (double.parse(humController.text) < widget.activeProfile.min_humidity! || double.parse(humController.text) > widget.activeProfile.max_humidity!) {
      return Colors.red;
    }
    return Colors.green;
  }

  Color isPresOk() {
    if (presController.text == '') {
      return Colors.green;
    }
    if (double.parse(presController.text) < widget.activeProfile.min_pressure! || double.parse(presController.text) > widget.activeProfile.max_pressure!) {
      return Colors.red;
    }
    return Colors.green;
  }

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
    return true;
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

  Widget _measurement(String title) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 100,
            height: 100,
            decoration: title== 'Temperatura'
                ? BoxDecoration(
                shape: BoxShape.circle,
                color: isTempOk())
                : title == 'Wilgotność'
                ? BoxDecoration(
                shape: BoxShape.circle,
                color: isHumOk())
                : BoxDecoration(
                shape: BoxShape.circle,
                color: isPresOk()),
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
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

import 'package:uuid/uuid.dart';



class Measures extends StatefulWidget {
  Measures({Key? key, required this.notifyParent}) : super(key: key);

  final Function() notifyParent;
  late Users user;
  late List<Profiles> userProfiles;
  late Profiles activeProfile;

  @override
  State<Measures> createState() => _MeasuresState();

  Future<void> _fetchCurrentUserAttributes() async {
    try {
      final result = await Amplify.Auth.fetchUserAttributes();
      for (final element in result) {
        print('key: ${element.userAttributeKey}; value: ${element.value}');
      }
      // get the email from the attributes
      final user = await Amplify.Auth.getCurrentUser();
      print("USERNAME=======================" + user.username);
      final username = user.username;
      _fetchUser(username);
      _fetchProfiles();
      _fetchActiveProfile();
    } on AuthException catch (e) {
      print(e.message);
    }
  }

  Future<void> _fetchUser(String username) async {
    try {
      print('Fetching user...');
      List<Users> usersList = await Amplify.DataStore.query(
        Users.classType,
        where: Users.USERNAME.eq(username),
      );
      if (usersList.length > 0) {
        user = usersList[0];
        print('User: ${user.id}');
      } else {
        print('User not found');
        // TODO: create user
        createUser(username);
      }
    } catch (e) {
      print("Could not query DataStore: " + e.toString());
      return;
    }
  }

  Future<void> createUser(String username) async {
    final newUser = Users(
        username: username,
        UserProfiles: []
    );
    final newProfile = Profiles(
        profile_name: 'Default',
        min_temperature: 17,
        max_temperature: 25,
        min_humidity: 40,
        max_humidity: 45,
        min_pressure: 1000,
        max_pressure: 1020,
        usersID: newUser.id
    );
    final newUserWithDefaultProfile = newUser.copyWith(
        active_profile_id: newProfile.id,
        UserProfiles: [newProfile]
    );
    try {
      // save the new User to the DataStore
      await Amplify.DataStore.save(newUserWithDefaultProfile);
      await Amplify.DataStore.save(newProfile);
      user = newUserWithDefaultProfile;
      userProfiles = newUserWithDefaultProfile.UserProfiles!;
      activeProfile = newProfile;
    } catch (e) {
      safePrint('An error occurred while saving a new User: $e');
    }
  }

  Future<void> _fetchProfiles() async {
    try {
      print('Fetching profiles...');
      userProfiles = await Amplify.DataStore.query(
        Profiles.classType,
        where: Profiles.USERSID.eq(user.id),
      );
    } catch (e) {
      print("Could not query DataStore: " + e.toString());
      return;
    }
  }

  Future<void> _fetchActiveProfile() async {
    try {
      print('Fetching active profile...');
      List<Profiles> activeProfileList = await Amplify.DataStore.query(
        Profiles.classType,
        where: Profiles.USERSID.eq(user.id).and(Profiles.ID.eq(user.active_profile_id)),
      );
      activeProfile = activeProfileList[0];
    } catch (e) {
      print("Could not query DataStore: " + e.toString());
      return;
    }
  }
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

    final user = await Amplify.Auth.getCurrentUser();
    String topic = '${user.userId}/sensorData';
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
    setState(() {});
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
      onTap: () async {
        final user = await Amplify.Auth.getCurrentUser();
        if (title == 'Zatrzymaj') {
          // Publish mqtt message to stop
          final mqtt.MqttClientPayloadBuilder builder = mqtt.MqttClientPayloadBuilder();
          builder.addString('{"Command": "Stop"}');
          client.publishMessage('${user.userId}/commands', MqttQos.atMostOnce, builder.payload!);
        } else {
          // Publish mqtt message to resume
          final mqtt.MqttClientPayloadBuilder builder = mqtt.MqttClientPayloadBuilder();
          builder.addString('{"Command": "Resume"}');
          client.publishMessage('${user.userId}/commands', MqttQos.atMostOnce, builder.payload!);
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

  @override
  void initState() {
    super.initState();
    widget._fetchCurrentUserAttributes();
    //mqttConnect(Uuid().v4());
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_app/screens/home.dart';
import 'package:iot_app/screens/welcome.dart';
import 'login.dart';
import 'register.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_api/amplify_api.dart'; // UNCOMMENT this line after backend is deployed

// Generated in previous step
import '../models/ModelProvider.dart';
import '../amplifyconfiguration.dart';
import '../models/Users.dart';
import '../models/Profiles.dart';

import 'package:android_flutter_wifi/android_flutter_wifi.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:restart_app/restart_app.dart';

import '../utils/RSAEncryption.dart';
import '../utils/AESEncryption.dart';

class WifiConnectPage extends StatefulWidget {
  WifiConnectPage(this.isRegistering, {Key? key}) : super(key: key);

  String? title;
  bool isRegistering;

  @override
  _WifiConnectState createState() => _WifiConnectState(isRegistering);
}

class _WifiConnectState extends State<WifiConnectPage>{
  _WifiConnectState(bool isReg){
    _isRegistering=isReg;
  }
  String _ssid = '';
  String _password = '';
  bool _isRegistering = false;
  late AESEncryption _aesEncryption;

  @override
  void initState() {
    super.initState();
    init();
  }
  void init() async {
    await AndroidFlutterWifi.init();
    await AndroidFlutterWifi.disableWifi();
    await AndroidFlutterWifi.enableWifi();
    _aesEncryption = AESEncryption();
  }


  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Wróć',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }



  Widget _entryField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              onChanged: (value) {
                setState(() {
                  if (title == 'Podaj SSID') {
                    _ssid = value;
                  } else if (title == 'Podaj hasło') {
                    _password = value;
                  }
                });
              },
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }
  Future<bool> _connectToAP() async {
    String ssid = "ESP32-Access-Point";
    String password = "IOTagh-2022";
    var isConnectedToAP = await AndroidFlutterWifi.connectToNetwork(ssid, password);
    if(!isConnectedToAP)_showNotConnectedDialog();
    return isConnectedToAP;
  }
  Future<void> _showNotConnectedDialog() async {
    EasyLoading.dismiss();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nie połączono z urządzeniem'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Upewnij się, że urządzenie jest włączone!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _showEmptySSIDDialog() async {
    EasyLoading.dismiss();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nie podano SSID'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('SSID jest polem wymaganym!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _showWrongWiFiCredentialsDialog() async {
    EasyLoading.dismiss();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Urządzenie nie może połączyć się z podanym WiFi'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Spróbuj ponownie'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<http.Response> _sendWiFiCredentials() async {
    var response= await http.get(
        Uri.parse('http://192.168.4.1')
    );
    var encryptedSSID = _aesEncryption.encrypt(_ssid);
    var encryptedPassword = _aesEncryption.encrypt(_password);
    await http.post(
      Uri.parse('http://192.168.4.1'),
      body:{
        'ssid': encryptedSSID,
        'pwd': encryptedPassword
      },
    );
    return response;
  }

  Future<bool> _isESPConnectedToWiFi() async {
    await Future.delayed(Duration(seconds: 6));
    String ssid = "ESP32-Access-Point";
    String password = "IOTagh-2022";
    var isAPAvailable = await AndroidFlutterWifi.connectToNetwork(ssid, password);
    if(isAPAvailable)_showWrongWiFiCredentialsDialog();
    return !isAPAvailable;
  }
  void _onclick() async{
    FocusManager.instance.primaryFocus?.unfocus();
    EasyLoading.instance
      ..userInteractions = false
      ..dismissOnTap = false;
    EasyLoading.show(status: 'ładowanie...');
    if(!await _connectToAP())return;
    if(_ssid==""){_showEmptySSIDDialog();return;}
    final response=await _sendWiFiCredentials();
    if(!await _isESPConnectedToWiFi())return;
    print("RESPONSE: ${response.body}");
    var decryptedResponse = _aesEncryption.decrypt(response.body.trim());
    if(_isRegistering){
      EasyLoading.dismiss();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SignUpPage(decryptedResponse)));
    }
    else
      Restart.restartApp();
  }
  Widget _submitButton() {
    return InkWell(
      onTap: () {
        _onclick();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
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
          'Połącz',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }


  Widget _title() {
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'IoT Projekt',
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Color(0xff057ace)),
        ));
  }

  Widget _ssidPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Podaj SSID"),
        _entryField("Podaj hasło", isPassword: true),
      ],
    );
  }

  Widget _header(bool isRegistering) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
              isRegistering?"Podaj dane:":"Zrestartuj urządzenie i podaj dane. Następnie zaloguj się ponownie.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
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
                    SizedBox(height: height * .2),
                    _title(),
                    SizedBox(height: 20),
                    _header(_isRegistering),
                    SizedBox(
                      height: 50,
                    ),
                    _ssidPasswordWidget(),
                    SizedBox(
                      height: 20,
                    ),
                    _submitButton(),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
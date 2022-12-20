import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_app/screens/register.dart';
import 'package:iot_app/screens/welcome.dart';

import 'login.dart';

import 'package:iot_app/screens/home.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_api/amplify_api.dart'; // UNCOMMENT this line after backend is deployed
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';

// Generated in previous step
import '../models/ModelProvider.dart';
import '../amplifyconfiguration.dart';
import '../models/Users.dart';
import '../models/Profiles.dart';

class AccessPointPage extends StatefulWidget {
  const AccessPointPage({Key? key}) : super(key: key);

  @override
  State<AccessPointPage> createState() => AccessPointState();
}

class AccessPointState extends State<AccessPointPage> {

  Future<void> signOutCurrentUserGlobally() async {
    try {
      await Amplify.Auth.signOut(options: SignOutOptions(globalSignOut: true));
    } on AmplifyException catch (e) {
      print(e.message);
    }
  }

  Widget _signOutButton() {
    return InkWell(
      onTap: () {
        signOutCurrentUserGlobally();
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Color(0xff1c98ad).withAlpha(100),
                  offset: Offset(2, 4),
                  blurRadius: 8,
                  spreadRadius: 2)
            ],
            color: Colors.white),
        child: Text(
          'Wyloguj się',
          style: TextStyle(fontSize: 20, color: Color(0xff057ace)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Access Point'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Access Point',
            ),
            SizedBox(height: 20),
            _signOutButton(),
          ],
        ),
      ),
    );
  }
}
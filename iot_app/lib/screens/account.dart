import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:iot_app/screens/wificonnect.dart';

// Generated in previous step
import '../models/ModelProvider.dart';
import '../models/Users.dart';
import '../models/Profiles.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class Account extends StatefulWidget {
  Account({Key? key, required this.user, required this.userProfiles, required this.activeProfile, required this.notifyParent}) : super(key: key);

  final Function() notifyParent;
  final Users user;
  List<Profiles> userProfiles;
  Profiles activeProfile;

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String _username = '';
  String _currentPassword = '';
  String _newPassword = '';

  Widget _entryField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
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
                if (title == 'Nazwa użytkownika: ' + widget.user.username) {
                  _username = value;
                } else if (title == 'Obecne hasło') {
                  _currentPassword = value;
                } else if (title == 'Nowe hasło') {
                  _newPassword = value;
                }
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

  Future<void> _changePassword() async {
    // get the current text field contents
    print("Obecne hasło: $_currentPassword");
    print("Nowe hasło: $_newPassword");
    if (sha1.convert(utf8.encode(_currentPassword)).toString() == widget.user.password) {
      final newUserChangedPassword = widget.user.copyWith(
          password: sha1.convert(utf8.encode(_newPassword)).toString()
      );

      // display AlertDialog to confirm the change
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Potwierdź zmianę hasła'),
            content: Text('Czy na pewno chcesz zmienić hasło na $_newPassword?'),
            actions: <Widget>[
              TextButton(
                child: Text('Anuluj'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Zmień'),
                onPressed: () async {
                  try {
                    // save the new User to the DataStore
                    await Amplify.DataStore.save(newUserChangedPassword);
                    setState(() {});
                  } catch (e) {
                    safePrint('An error occurred while updating User: $e');
                    // show a failure message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Wystąpił błąd. Nie zachowano zmian.'),
                      ),
                    );
                    Navigator.of(context).pop();
                    return;
                  }
                  // show a success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hasło została zmieniona'),
                    ),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Obecne hasło jest niepoprawne'),
        ),
      );
    }
  }

  Future<bool> _userExists() async {
    // get the current text field contents
    try {
      List<Users> users = await Amplify.DataStore.query(
          Users.classType,
          where: Users.USERNAME.eq(_username)
      );
       if(users.isNotEmpty) {
        if (users[0].username == _username && users[0].id != widget.user.id) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Could not query DataStore: " + e.toString());
      return false;
    }
  }

  Future<void> _changeUsername() async {
    print("Nazwa użytkownika: $_username");
    // get the current text field contents
    if (await _userExists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Użytkownik o takiej nazwie już istnieje'),
        ),
      );
    } else {
      final newUserChangedUsername = widget.user.copyWith(
          username: _username
      );
      // display AlertDialog to confirm the change
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Potwierdź zmianę nazwy użytkownika'),
            content: Text('Czy na pewno chcesz zmienić nazwę użytkownika na $_username?'),
            actions: <Widget>[
              TextButton(
                child: Text('Anuluj'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Zmień'),
                onPressed: () async {
                  try {
                    // save the new User to the DataStore
                    await Amplify.DataStore.save(newUserChangedUsername);
                    setState(() {});
                  } catch (e) {
                    safePrint('An error occurred while updating User: $e');
                    // show a failure message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Wystąpił błąd. Nie zachowano zmian.'),
                      ),
                    );
                    Navigator.of(context).pop();
                    return;
                  }
                  // show a success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Nazwa użytkownika została zmieniona'),
                    ),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }


  Widget _submitButton(String text) {
    return InkWell(
      onTap: () {
        if (text == "Zmień hasło") {
          _changePassword();
          // TODO: clear the text fields
        } else if (text == "Zmień nazwę") {
          _changeUsername();
          // TODO: clear the text fields
        } else if (text == "Zmień/podłącz płytkę") {
          // TODO: clear the text fields
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => WifiConnectPage(user: widget.user, userProfiles: widget.userProfiles, activeProfile: widget.activeProfile, isRegistering: false)));
        }
        widget.notifyParent();
      },
      child: Container(
        width: MediaQuery.of(context).size.width/2,
        padding: EdgeInsets.symmetric(vertical: 5),
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
        child: Text(text,
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }

  Widget _newPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Obecne hasło", isPassword: true),
        _entryField("Nowe hasło", isPassword: true)
      ],
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
                      SizedBox(height: 15),
                      _entryField("Nazwa użytkownika: " + widget.user.username),
                      SizedBox(height: 15),
                      _submitButton("Zmień nazwę"),
                      SizedBox(height: 15),
                      _newPasswordWidget(),
                      SizedBox(height: 15),
                      _submitButton("Zmień hasło"),
                      SizedBox(height: 25),
                      _submitButton("Zmień/podłącz płytkę"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
// import 'package:amplify_api/amplify_api.dart'; // UNCOMMENT this line after backend is deployed

// Generated in previous step
import '../models/ModelProvider.dart';
import '../amplifyconfiguration.dart';
import '../models/Users.dart';
import '../models/Profiles.dart';

class Account extends StatefulWidget {
  const Account({Key? key, required this.user}) : super(key: key);

  final Users user;

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String _username = '';
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmNewPassword = '';

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
              if (title == 'Nazwa użytkownika: ' + widget.user.username) {
                _username = value;
              } else if (title == 'Obecne hasło') {
                _currentPassword = value;
              } else if (title == 'Nowe hasło') {
                _newPassword = value;
              } else if (title == 'Potwierdź nowe hasło') {
                _confirmNewPassword = value;
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
    print("Potwierdź nowe hasło: $_confirmNewPassword");
    if (_newPassword == _confirmNewPassword && _currentPassword == widget.user.password) {
      final newUserChangedPassword = widget.user.copyWith(
          password: _newPassword
      );
      try {
        // save the new User to the DataStore
        await Amplify.DataStore.save(newUserChangedPassword);
        setState(() {});
      } catch (e) {
        safePrint('An error occurred while saving a new User: $e');
        return;
      }
      // show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hasło zostało zmienione'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hasła nie są takie same'),
        ),
      );
    }
  }

  Future<bool> _userExists() async {
    // get the current text field contents
    try {
      List<Users> users = await Amplify.DataStore.query(Users.classType);
      for (Users user in users) {
        if (user.username == _username && user.id != widget.user.id) {
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
      try {
        // save the new User to the DataStore
        await Amplify.DataStore.save(newUserChangedUsername);
        // refresh the UI
        setState(() {});
        // show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nazwa użytkownika została zmieniona'),
          ),
        );
      } catch (e) {
        safePrint('An error occurred while saving a new User: $e');
      }
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
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width/2,
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
        child: Text(text,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _newPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Obecne hasło", isPassword: true),
        _entryField("Nowe hasło", isPassword: true),
        _entryField("Potwierdź nowe hasło", isPassword: true),
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
                      SizedBox(height: 20),
                      _entryField("Nazwa użytkownika: " + widget.user.username),
                      SizedBox(height: 20),
                      _submitButton("Zmień nazwę"),
                      SizedBox(height: 20),
                      _newPasswordWidget(),
                      SizedBox(height: 20),
                      _submitButton("Zmień hasło"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

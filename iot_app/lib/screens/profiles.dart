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
import 'home.dart';

class ProfilesScreen extends StatefulWidget {
  ProfilesScreen({Key? key, required this.user, required this.userProfiles, required this.activeProfile, required this.notifyParent}) : super(key: key);

  final Function() notifyParent;
  Users user;
  List<Profiles> userProfiles;
  Profiles activeProfile;

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  String newProfileName = '';
  double minTemp = 0;
  double maxTemp = 0;
  double minHum = 0;
  double maxHum = 0;
  double minPres = 0;
  double maxPres = 0;
  TextEditingController minTempController = TextEditingController();
  TextEditingController maxTempController = TextEditingController();
  TextEditingController minHumController = TextEditingController();
  TextEditingController maxHumController = TextEditingController();
  TextEditingController minPressController = TextEditingController();
  TextEditingController maxPressController = TextEditingController();
  TextEditingController newProfileNameController = TextEditingController();
  String profileToDelete = '';
  String activeSelectedProfile = '';


  Widget _picker() {
    List<String> testList = [];
    if (widget.userProfiles != null) {
      for (Profiles profile in widget.userProfiles) {
        testList.add(profile.profile_name);
      }
    }
    setState(() {
      if (profileToDelete == '') {
        profileToDelete = testList[0];
      } else {
        profileToDelete = profileToDelete;
      }
    });

    return DropdownButton<String>(
      value: profileToDelete,
      style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xff057ace)),
      onChanged: (String? value) {
        setState(() {
          profileToDelete = value!;
        });
      },
      items: testList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Future<void> _addProfile() async {
    // get the current text field contents
    try {
      if (minTemp >= maxTemp || minHum >= maxHum || minPres >= maxPres) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wartości minimalne nie mogą być większe ani równe maksymalnym'),
          ),
        );
        return;
      }
      if (newProfileName == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nazwa profilu nie może być pusta'),
          ),
        );
        return;
      }
      final newProfile = Profiles(
          profile_name: newProfileName,
          min_temperature: minTemp,
          max_temperature: maxTemp,
          min_humidity: minHum,
          max_humidity: maxHum,
          usersID: widget.user.id);
      await Amplify.DataStore.save(newProfile);
      final newUser = widget.user.copyWith(
          UserProfiles: widget.userProfiles + [newProfile]);
      await Amplify.DataStore.save(newUser);
      widget.user = newUser;
      widget.userProfiles = await Amplify.DataStore.query(
        Profiles.classType,
        where: Profiles.USERSID.eq(widget.user.id),
      );;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dodano profil'),
        ),
      );
      // refresh the UI
    } catch (e) {
      print("Could not query DataStore: " + e.toString());
      // show a failure message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wystąpił błąd. Zmiany zachowano zmian.'),
        ),
      );
      return;
    }
  }

  Future<void> _deleteProfile() async {
    // get the current text field contents
    if (profileToDelete == 'Default') {
      // show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nie można usunąć domyślnego profilu')
        ),
      );
      return;
    }
    if (profileToDelete == widget.activeProfile.profile_name) {
      // show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nie można usunąć aktywnego profilu')
        ),
      );
      return;
    }
    try {
      List<Profiles> profilesToDelete = await Amplify.DataStore.query(
        Profiles.classType,
        where: Profiles.PROFILE_NAME.eq(profileToDelete),
      );
      if (profilesToDelete.isNotEmpty) {
        print('Deleting profile: ' + profilesToDelete[0].profile_name);
        await Amplify.DataStore.delete(profilesToDelete.first);
        widget.userProfiles.remove(profilesToDelete.first);
        print("===========Updated userProfiles: " + widget.userProfiles.toString());
        final newUser = widget.user.copyWith(
            UserProfiles: widget.userProfiles);
        widget.user = newUser;
        await Amplify.DataStore.save(newUser);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usunięto profil'),
          ),
        );
      }
    } catch (e) {
      print("Could not query DataStore: " + e.toString());
      // show a failure message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wystąpił błąd. Zmiany zachowano zmian.'),
        ),
      );
      return;
    }
  }

  Future<void> setActiveProfile() async {
    widget.activeProfile = widget.userProfiles.firstWhere((element) => element.profile_name == activeSelectedProfile);
    final newUserChangedActiveProfile = widget.user.copyWith(
        active_profile_id: widget.activeProfile.id
    );
    await Amplify.DataStore.save(newUserChangedActiveProfile);
    // Display scaffold message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Zmieniono aktywny profil na ' + widget.activeProfile.profile_name),
        duration: Duration(seconds: 2),
      ),
    );
    widget.notifyParent();
  }

  Widget _activeProfilePicker() {
    List<String> testList = [];
    if (widget.userProfiles != null) {
      for (Profiles profile in widget.userProfiles) {
        testList.add(profile.profile_name);
      }
    }
    setState(() {
      if (activeSelectedProfile == '') {
        activeSelectedProfile = widget.activeProfile.profile_name;
      } else {
        activeSelectedProfile = activeSelectedProfile;
      }
    });

    return DropdownButton<String>(
      value: activeSelectedProfile,
      style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xff057ace)),
      onChanged: (String? value) {
        setState(() {
          activeSelectedProfile = value!;
          // setActiveProfile();
        });
      },
      items: testList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _activeProfilePickerSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          'Aktywny profil',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          width: 10,
        ),
        _activeProfilePicker(),
      ],
    );
  }

  Widget _button(String title) {
    return InkWell(
      onTap: () {
        if (title == 'Dodaj') {
          // display AlertDialog to confirm the change
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Potwierdź dodanie profilu'),
                content: Text('Czy na pewno chcesz dodać profil $newProfileName?'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Anuluj'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Dodaj'),
                    onPressed: () async {
                      _addProfile();
                      // show a success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Profil został dodany'),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else if (title == 'Usuń') {
          // display AlertDialog to confirm the change
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Potwierdź usunięcie profilu'),
                content: Text('Czy na pewno chcesz usunąć profil $profileToDelete?'),
                actions: <Widget>[
                  TextButton(
                    child: Text('Anuluj'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Usuń'),
                    onPressed: () async {
                      _deleteProfile();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else if(title == 'Aktywuj') {
          // TODO: implement
          // display AlertDialog to confirm the change
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Potwierdź zmianę aktywnego profilu'),
                content: Text('Czy na pewno chcesz zmienić aktywny profil na $activeSelectedProfile?'),
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
                        setActiveProfile();
                        // refresh the UI
                        setState(() {});
                      } catch (e) {
                        safePrint('An error occurred while changing device ID: $e');
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
                          content: Text('Aktywny profil został zmieniony'),
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
        widget.notifyParent();
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
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

  Widget _entryField({String fieldFor='', double width = 75}) {
    return Container(
      width: width,
      margin: EdgeInsets.symmetric(vertical: 15),
      child: TextField(
          controller: fieldFor == 'minTemp' ? minTempController : fieldFor == 'maxTemp' ? maxTempController : fieldFor == 'minHum' ? minHumController : fieldFor == 'maxHum' ? maxHumController : fieldFor == 'minPres' ? minPressController : fieldFor == 'maxPres' ? maxPressController : newProfileNameController,
          onChanged: (value) {
            if (fieldFor == 'profileName') {
              newProfileName = value;
            } else if (fieldFor == 'minTemp') {
              minTemp = double.parse(value);
            } else if (fieldFor == 'maxTemp') {
              maxTemp = double.parse(value);
            } else if (fieldFor == 'minHum') {
              minHum = double.parse(value);
            } else if (fieldFor == 'maxHum') {
              maxHum = double.parse(value);
            } else if (fieldFor == 'minPres') {
              minPres = double.parse(value);
            } else if (fieldFor == 'maxPres') {
              maxPres = double.parse(value);
            }
          },
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true)),
    );
  }

  Widget _entryColumn(String title, String fieldFor1, String fieldFor2, String fieldFor3) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            _entryField(fieldFor: fieldFor1)
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            _entryField(fieldFor: fieldFor2)
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            _entryField(fieldFor: fieldFor3)
          ]),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    minTempController.text = minTemp.toString();
    maxTempController.text = maxTemp.toString();
    minHumController.text = minHum.toString();
    maxHumController.text = maxHum.toString();
    minPressController.text = minPres.toString();
    maxPressController.text = maxPres.toString();
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[_picker(), _button("Usuń")]),
                  SizedBox(height: 50),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Dodaj profil",
                        style: TextStyle(fontSize: 20),
                      )),
                  SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
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
                  SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          "Nazwa profilu",
                          style: TextStyle(fontSize: 15),
                        ),
                        _entryField(fieldFor: "profileName", width: 100),
                        _button("Dodaj"),
                      ]),
                  // SizedBox(height: 20),
                  // _button("Dodaj"),
                  SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[_activeProfilePickerSelector(), _button("Aktywuj")]),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

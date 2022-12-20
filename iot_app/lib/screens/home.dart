import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_app/screens/account.dart';
import 'package:iot_app/screens/ap_connect.dart';
import 'package:iot_app/screens/measurements.dart';
import 'package:iot_app/screens/profiles.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
// import 'package:amplify_api/amplify_api.dart'; // UNCOMMENT this line after backend is deployed

// Generated in previous step
import '../models/ModelProvider.dart';
import '../amplifyconfiguration.dart';
import '../models/Users.dart';
import '../models/Profiles.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  late Users user;
  late List<Profiles> userProfiles;
  late Profiles activeProfile;

  refresh() async {
    print(" ===REFRESH=== " );
    _fetchCurrentUserAttributes();
  }

  @override
  State<HomePage> createState() => _HomePageState();

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
      print(" ===INFO===" );
      print("user: " + user.toString());
      print("userProfiles: " + userProfiles.toString());
      print("activeProfile: " + activeProfile.toString());
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

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    widget._fetchCurrentUserAttributes();
  }

  @override
  Widget build(BuildContext context) {
    widget._fetchCurrentUserAttributes();
    final height = MediaQuery.of(context).size.height;
    return DefaultTabController(
      // Update user and userProfiles when the tab is changed
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                widget.refresh();
              });
            },
            tabs: [
              Tab(text: "Pomiary"),
              Tab(text: "Profile"),
              Tab(text: "Konto"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Measures(notifyParent: widget.refresh),
            ProfilesScreen(notifyParent: widget.refresh),
            Account(notifyParent: widget.refresh),
            AccessPointPage(),
          ],
        ),
      ),
    );
  }
}

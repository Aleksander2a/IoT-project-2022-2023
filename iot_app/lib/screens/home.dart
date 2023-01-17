import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_app/screens/account.dart';
import 'package:iot_app/screens/measurements.dart';
import 'package:iot_app/screens/profiles.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify_flutter.dart';

// Generated in previous step
import '../models/ModelProvider.dart';
import '../models/Users.dart';
import '../models/Profiles.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.user, required this.userProfiles, required this.activeProfile}) : super(key: key);

  Users user;
  List<Profiles> userProfiles;
  Profiles activeProfile;
  String state = 'off';

  refresh() async {
    state = 'on';
    print(" ====== " + state);
    _fetchUser();
    _fetchProfiles();
    _fetchActiveProfile();
    _fetchActiveProfile();
  }

  @override
  State<HomePage> createState() => _HomePageState();

  Future<void> _fetchUser() async {
    try {
      print('Fetching user...');
      List<Users> usersList = await Amplify.DataStore.query(
        Users.classType,
        where: Users.ID.eq(user.id),
      );
      user = usersList[0];
    } catch (e) {
      print("Could not query DataStore: " + e.toString());
      return;
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
  Widget build(BuildContext context) {
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
            Measures(user: widget.user, userProfiles: widget.userProfiles, activeProfile: widget.activeProfile, notifyParent: widget.refresh),
            ProfilesScreen(user: widget.user, userProfiles: widget.userProfiles, activeProfile: widget.activeProfile, notifyParent: widget.refresh),
            Account(user: widget.user, userProfiles: widget.userProfiles, activeProfile: widget.activeProfile, notifyParent: widget.refresh),
          ],
        ),
      ),
    );
  }
}

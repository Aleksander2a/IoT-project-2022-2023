import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_app/screens/account.dart';
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
  HomePage({Key? key, required this.user, required this.userProfiles}) : super(key: key);

  final Users user;
  List<Profiles> userProfiles;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "Pomiary"),
              Tab(text: "Profile"),
              Tab(text: "Konto"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Measures(),
            ProfilesScreen(user: widget.user, userProfiles: widget.userProfiles),
            Account(user: widget.user),
          ],
        ),
      ),
    );
  }
}

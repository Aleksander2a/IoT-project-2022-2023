// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:iot_app/screens/home.dart';
// import 'package:iot_app/screens/register.dart';
//
// // Amplify Flutter Packages
// import 'package:amplify_flutter/amplify_flutter.dart';
// import 'package:amplify_datastore/amplify_datastore.dart';
// import 'package:amplify_api/amplify_api.dart'; // UNCOMMENT this line after backend is deployed
//
// // Generated in previous step
// import '../models/ModelProvider.dart';
// import '../amplifyconfiguration.dart';
// import '../models/Users.dart';
// import '../models/Profiles.dart';
//
// class LoginPage extends StatefulWidget {
//   LoginPage({Key? key, this.title}) : super(key: key);
//
//   final String? title;
//
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   // loading ui state - initially set to a loading state
//   bool _isLoading = true;
//   String _username = '';
//   String _password = '';
//   List<String> profileNames = [];
//
//   // @override
//   // void initState() {
//   //   // kick off app initialization
//   //   _initializeApp();
//   //   super.initState();
//   // }
//   //
//   // @override
//   // void dispose() {
//   //   super.dispose();
//   //   // to be filled in a later step
//   // }
//   //
//   // Future<void> _initializeApp() async {
//   //   // configure Amplify
//   //   await _configureAmplify();
//   //
//   //   // after configuring Amplify, update loading ui state to loaded state
//   //   setState(() {
//   //     _isLoading = false;
//   //   });
//   // }
//   //
//   // Future<void> _configureAmplify() async {
//   //   try {
//   //
//   //     // amplify plugins
//   //     final _dataStorePlugin = AmplifyDataStore(modelProvider: ModelProvider.instance);
//   //
//   //     // Add the following line and update your function call with `addPlugins`
//   //     final api = AmplifyAPI();
//   //
//   //     // add Amplify plugins
//   //     await Amplify.addPlugins([_dataStorePlugin, api]);
//   //
//   //     // configure Amplify
//   //     //
//   //     // note that Amplify cannot be configured more than once!
//   //     await Amplify.configure(amplifyconfig);
//   //   } catch (e) {
//   //
//   //     // error handling can be improved for sure!
//   //     // but this will be sufficient for the purposes of this tutorial
//   //     safePrint('An error occurred while configuring Amplify: $e');
//   //   }
//   // }
//
//   Future<void> _getUser() async {
//     // get the current text field contents
//     try {
//       List<Users> users = await Amplify.DataStore.query(Users.classType);
//       for (Users user in users) {
//         if (user.username == _username && user.password == _password) {
//           List<Profiles> userProfiles = await Amplify.DataStore.query(
//             Profiles.classType,
//             where: Profiles.USERSID.eq(user.id),
//           );
//           List<Profiles> activeProfileList = await Amplify.DataStore.query(
//             Profiles.classType,
//             where: Profiles.USERSID.eq(user.id).and(Profiles.ID.eq(user.active_profile_id)),
//           );
//           Profiles activeProfile = activeProfileList[0];
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => HomePage(user: user, userProfiles: userProfiles, activeProfile: activeProfile)),
//           );
//           return;
//         }
//       }
//       print("Wrong username or password");
//       // Display scaffold message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Błędna nazwa lub hasło'),
//           duration: Duration(seconds: 3),
//         ),
//       );
//     } catch (e) {
//       print("Could not query DataStore: " + e.toString());
//     }
//   }
//
//   Widget _backButton() {
//     return InkWell(
//       onTap: () {
//         Navigator.pop(context);
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 10),
//         child: Row(
//           children: <Widget>[
//             Container(
//               padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
//               child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
//             ),
//             Text('Wróć',
//                 style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _entryField(String title, {bool isPassword = false}) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           Text(
//             title,
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           TextField(
//               onChanged: (value) {
//                 setState(() {
//                   if (title == 'Nazwa') {
//                     _username = value;
//                   } else if (title == 'Hasło') {
//                     _password = value;
//                   }
//                 });
//               },
//               obscureText: isPassword,
//               decoration: InputDecoration(
//                   border: InputBorder.none,
//                   fillColor: Color(0xfff3f3f4),
//                   filled: true))
//         ],
//       ),
//     );
//   }
//
//   Widget _submitButton() {
//     return InkWell(
//       onTap: () {
//         _getUser();
//       },
//       child: Container(
//         width: MediaQuery.of(context).size.width,
//         padding: EdgeInsets.symmetric(vertical: 15),
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.all(Radius.circular(5)),
//             boxShadow: <BoxShadow>[
//               BoxShadow(
//                   color: Colors.grey.shade200,
//                   offset: Offset(2, 4),
//                   blurRadius: 5,
//                   spreadRadius: 2)
//             ],
//             gradient: LinearGradient(
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//                 colors: [Color(0xff1c98ad), Color(0xff057ace)])),
//         child: Text(
//           'Zaloguj',
//           style: TextStyle(fontSize: 20, color: Colors.white),
//         ),
//       ),
//     );
//   }
//
//   Widget _createAccountLabel() {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//             context, MaterialPageRoute(builder: (context) => SignUpPage()));
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 20),
//         padding: EdgeInsets.all(15),
//         alignment: Alignment.bottomCenter,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Nie masz jeszcze konta?',
//               style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//             ),
//             SizedBox(
//               width: 10,
//             ),
//             Text(
//               'Zarejestruj się',
//               style: TextStyle(
//                   color: Color(0xff057ace),
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _title() {
//     return RichText(
//         textAlign: TextAlign.center,
//         text: TextSpan(
//           text: 'IoT Projekt',
//           style: TextStyle(
//               fontSize: 30,
//               fontWeight: FontWeight.w700,
//               color: Color(0xff057ace)),
//         ));
//   }
//
//   Widget _emailPasswordWidget() {
//     return Column(
//       children: <Widget>[
//         _entryField("Nazwa"),
//         _entryField("Hasło", isPassword: true),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     return Scaffold(
//         body: Container(
//       height: height,
//       child: Stack(
//         children: <Widget>[
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   SizedBox(height: height * .2),
//                   _title(),
//                   SizedBox(height: 50),
//                   _emailPasswordWidget(),
//                   SizedBox(height: 20),
//                   _submitButton(),
//                   SizedBox(height: height * .055),
//                   _createAccountLabel(),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(top: 40, left: 0, child: _backButton()),
//         ],
//       ),
//     ));
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/src/widgets/automatic_keep_alive.dart';

class Measures extends StatefulWidget {
  const Measures({Key? key}) : super(key: key);

  @override
  State<Measures> createState() => _MeasuresState();
}

class _MeasuresState extends State<Measures>
    with AutomaticKeepAliveClientMixin {

  Widget _picker() {
    const List<String> testList = <String>['One', 'Two', 'Three'];
    String dropdownValue = testList.first;

    return DropdownButton<String>(
      value: dropdownValue,
      style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xff057ace)),
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
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

  Widget _profilePicker() {
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
        _picker(),
      ],
    );
  }

  Widget _status() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(
          'Status urządzenia',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          width: 150,
          height: 50,
          child: Card(child: Center(child: Text("placeholder"))),
        ),
      ],
    );
  }

  Widget _measurement(String title) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 100,
            height: 100,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.blue[100]),
            child: Center(
              child: Text("placeholder",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
      onTap: () {
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
              SizedBox(height: 20),
              _button("Wyłącz")
              ]
        ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _button("Wznów"),
                SizedBox(height: 20),
                _button("Włącz")
              ]
          ),
        ],);
  }

  @override
  bool get wantKeepAlive => true;

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
                  _status(),
                  SizedBox(height: 50),
                  _profilePicker(),
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
}

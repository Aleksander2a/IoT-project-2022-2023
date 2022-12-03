import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Profiles extends StatefulWidget {
  const Profiles({Key? key}) : super(key: key);

  @override
  State<Profiles> createState() => _ProfilesState();
}

class _ProfilesState extends State<Profiles> {
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

  Widget _button(String title) {
    return InkWell(
      onTap: () {},
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

  Widget _entryField({double width = 75}) {
    return Container(
      width: width,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true)),
    );
  }

  Widget _eraseButton() {
    return InkWell(
      onTap: () {},
      child: Container(
        width: 25,
        height: 25,
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
          "X",
          style: TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }

  Widget _entryColumn(String title) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            _entryField(),
            _eraseButton(),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            _entryField(),
            _eraseButton(),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            _entryField(),
            _eraseButton(),
          ]),
        ]);
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
                        _entryColumn("MIN"),
                        _entryColumn("MAX"),
                      ]),
                  SizedBox(height: 20),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          "Nazwa profilu",
                          style: TextStyle(fontSize: 15),
                        ),
                        _entryField(width: 150),
                      ]),
                  SizedBox(height: 20),
                  _button("Dodaj")
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

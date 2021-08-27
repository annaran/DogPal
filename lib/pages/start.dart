import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Start extends StatefulWidget {
  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {
  SharedPreferences logindata;

  @override
  void initState() {
    super.initState();
    loggedUserCheck();
  }

  void loggedUserCheck() async {
    logindata = await SharedPreferences.getInstance();
    if (logindata.getBool('islogged') == true) {
      Navigator.pushReplacementNamed(context, "/ownerprofile");
    } else {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown,
      appBar: AppBar(
        title: Text('DogPal'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SpinKitRotatingCircle(
        color: Colors.amber,
        size: 50.0,
      ),
    );
  }
}

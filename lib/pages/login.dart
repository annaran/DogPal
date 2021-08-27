import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dogwalker2/api_urls.dart';

class Login extends StatefulWidget {
  Login({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  //SharedPreferences logindata;

  Future login() async {
    String url = url_login;
    Response response = await http.post(url, body: {
      "email": email.text,
      "password": password.text,
    });

    Map data = json.decode(response.body);

    if (data['status'] == "Error") {
      print(data.toString());

      Fluttertoast.showToast(
        msg: data['msg'],
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
      );
    } else {
      SharedPreferences logindata;
      logindata = await SharedPreferences.getInstance();
      logindata.setBool('islogged', true);
      logindata.setString('email', email.text);
      logindata.setString('userid', data['userid']);
      Fluttertoast.showToast(
        msg: 'Login successful',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.lightGreen,
      );

      Navigator.pushNamed(context, "/ownerprofile");
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
        leading: new Container(),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Card(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    controller: email,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    controller: password,
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    login();
                  },
                  child: Text(
                    'Login',
                  ),
                ),
                Row(children: <Widget>[
                  Expanded(child: Divider()),
                  Text("OR"),
                  Expanded(child: Divider()),
                ]),
                RaisedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/register");
                  },
                  child: Text(
                    "Register a new account",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

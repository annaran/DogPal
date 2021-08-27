import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dogwalker2/api_urls.dart';
import 'package:http/http.dart';

class Register extends StatefulWidget {
  Register({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController password2 = TextEditingController();

  Future register() async {
    String url = url_register;
    Response response = await http.post(url, body: {
      "email": email.text,
      "password": password.text,
      "password2": password2.text
    });


    Map data = json.decode(response.body);
    print(data.toString());
    if (data['status'] != "Success") {   
      Fluttertoast.showToast(
        msg: data['msg'],
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
      );
    } else {
      print(data.toString());
      Fluttertoast.showToast(
        msg: data['msg'],
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
      );
      Navigator.pushNamed(context, "/login");
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    password2.dispose();
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
      body: SafeArea(
        child: Container(      
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Repeat password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      controller: password2,
                    ),
                  ),
                  RaisedButton(
                    onPressed: () {
                      register();
                    },
                    child: Text(
                      'Register',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

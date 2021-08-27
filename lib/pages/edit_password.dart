import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dogwalker2/api_urls.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditPassword extends StatefulWidget {
  EditPassword({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _EditPasswordState createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  SharedPreferences logindata;
  String userid;

  TextEditingController password = TextEditingController();
  TextEditingController newpassword = TextEditingController();
  TextEditingController newpassword2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      userid = logindata.getString('userid');
    });
  }

  Future updatePassword() async {
    var url = url_updatepassword;
    Response response = await http.post(url, body: {
      'id': userid,
      'password': password.text,
      'newpassword': newpassword.text,
      'newpassword2': newpassword2.text,
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
      print(data.toString());

      Fluttertoast.showToast(
        msg: data['msg'],
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.lightGreen,
      );
      Navigator.of(context).pop();
      Navigator.pushReplacementNamed(context, "/ownerprofile");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        child: Card(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current password',
                    prefixIcon: Icon(Icons.person),
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
                    labelText: 'New password',
                    prefixIcon: Icon(Icons.location_city),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  controller: newpassword,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Repeat new password',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  controller: newpassword2,
                ),
              ),
              RaisedButton(
                onPressed: () {
                  updatePassword();
                },
                child: Text(
                  'Update',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dogwalker2/api_urls.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditOwnerProfile extends StatefulWidget {
  EditOwnerProfile({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _EditOwnerProfileState createState() => _EditOwnerProfileState();
}

class _EditOwnerProfileState extends State<EditOwnerProfile> {
  SharedPreferences logindata;
  String userid;
  TextEditingController displayname = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController description = TextEditingController();

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

    loadProfileData();
  }

  Future updateProfile() async {
    var url = url_updateprofiledata;
    Response response = await http.post(url, body: {
      'id': userid.toString(),
      'displayname': displayname.text,
      'location': location.text,
      'email': email.text,
      'description': description.text,
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
        msg: 'Profile update successful',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.lightGreen,
      );
      Navigator.of(context).pop();
      Navigator.pushReplacementNamed(context, "/ownerprofile");
    }
  }

  Future loadProfileData() async {
    String url = url_loadprofiledata + '?id=' + userid;
    print(url);
    Response response = await http.get(url);

    Map data = json.decode(response.body);
    print(data.toString());

    // initializing text controller with values from db
    displayname.text = data['displayname'];
    email.text = data['email'];
    location.text = data['location'];
    description.text = data['description'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
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
                    decoration: InputDecoration(
                      labelText: 'Display name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    controller: displayname,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Location',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    controller: location,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    controller: description,
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    updateProfile();
                  },
                  child: Text(
                    'Update',
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

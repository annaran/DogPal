import 'package:dogwalker2/pages/view_owner_profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dogwalker2/api_urls.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'filter_users.dart';

class ListUsers extends StatefulWidget {
  ListUsers({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ListUsersState createState() => _ListUsersState();
}

class _ListUsersState extends State<ListUsers> {
  List data;
  SharedPreferences logindata;
  String userid;


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
    getUsersData();
  }

  Future getUsersData() async {
    print(userid);
    String url = url_listusers + '?id=' + userid;
    Response response = await http.get(url);

    setState(() {

      data = jsonDecode(response.body);
    });
    print(data.toString());
    return "Successful";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FilterUsers(title: "Filter")));
                },
                child: Icon(
                  Icons.search,
                  size: 26.0,
                ),
              )),
        ],
      ),
      body: Container(color: Colors.grey[400], child: _buildListView()),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: data == null ? 0 : data.length,
        itemBuilder: (context, index) {
          return _buildRow(data[index]);
        });
  }

  Widget _buildRow(dynamic item) {
    return Card(
      child: ListTile(
        title: Text(
          item['displayname'] ?? 'Unspecified',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.brown[300],
          ),
        ),
        subtitle: Text(item['location'] ?? 'Unspecified'),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.brown,
          child: CircleAvatar(
            radius: 26,
            backgroundImage: item['url'] == null
                ? NetworkImage(path_images + 'default_avatar.png')
                : NetworkImage(path_images + item['url']),
          ),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ViewOwnerProfile(title: "Profile", id: item['id']),
              ));
        },
      ),
    );
  }
}

import 'package:dogwalker2/pages/view_owner_profile.dart';
import 'package:flutter/material.dart';
import 'package:dogwalker2/api_urls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'filter_users.dart';

class FilteredUsers extends StatefulWidget {
  FilteredUsers({Key key, this.title, @required this.filteredUsersData})
      : super(key: key);
  final String title;
  final List filteredUsersData;

  @override
  _FilteredUsersState createState() => _FilteredUsersState();
}

class _FilteredUsersState extends State<FilteredUsers> {
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
      data = widget.filteredUsersData;
    });
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
          return _buildRowProfiles(data[index]);
        });
  }

  Widget _buildRowProfiles(dynamic item) {
    return Card(
      child: ListTile(
        title: Text(
          item['displayname'] == null ? '' : item['displayname'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.brown[300],
          ),
        ),
        subtitle: Text(item['location'] == null ? '' : item['location']),
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
                    ViewOwnerProfile(title: "Walker profile", id: item['id']),
              ));
        },
      ),
    );
  }
}

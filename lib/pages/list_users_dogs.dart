import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; //dart:convert allows us to convert the response to json (jsonDecode)
import 'package:dogwalker2/api_urls.dart';
import 'package:http/http.dart';
import 'package:dogwalker2/pages/view_dog_profile.dart';

class ListUsersDogs extends StatefulWidget {
  ListUsersDogs({Key key, this.title, @required this.id}) : super(key: key);
  final String title;
  final String id;

  @override
  _ListUsersDogsState createState() => _ListUsersDogsState();
}

class _ListUsersDogsState extends State<ListUsersDogs> {
  List data;


  @override
  void initState() {
    super.initState();
    // Call the getData() method when the app initializes
    getData();
  }



  Future getData() async {
    String url = url_listmydogs + '?id=' + widget.id;
    Response response = await http.get(url);
    // response.body is a String, we have to decode it to json to get to the properties
    // var data = jsonDecode(response.body);

// to change the state we need to use setState method
// it triggers the build function that rebuilds the widget with the new values
    setState(() {
      // Get the JSON data
      data = jsonDecode(response.body);
    });
    print(data.toString());
    return "Successfull";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
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
    return Card (
          child: ListTile(
        title: Text(
          item['name'] == null ? '' : item['name'],
        ),
        subtitle: Text(
          item['breed']  == null ? '' : item['breed']
          ),
              leading: CircleAvatar(
          backgroundImage: item['url'] == null ? NetworkImage(path_images+'default_dog.png') : NetworkImage(path_images+item['url']),
          ),
                onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ViewDogProfile(title: "Dog profile", id: item['id']),
              ));
        },
      ),
    );
  }



}

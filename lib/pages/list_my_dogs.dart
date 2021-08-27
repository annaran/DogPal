import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dogwalker2/api_urls.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dogwalker2/pages/dog_profile.dart';
import 'package:dogwalker2/pages/add_dog.dart';

class ListMyDogs extends StatefulWidget {
  ListMyDogs({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ListMyDogsState createState() => _ListMyDogsState();
}

class _ListMyDogsState extends State<ListMyDogs> {
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
    getDogsData();
  }

  void refreshData() {
    getDogsData();
  }

  Future getDogsData() async {
    String url = url_listmydogs + '?id=' + userid;
    Response response = await http.get(url);

    setState(() {
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddDog(
                  title: "Add dog",
                  refreshData: refreshData,
                ),
              ));
        },
        label: Text('Add'),
        icon: Icon(Icons.pets_rounded),
      ),
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
        title: Text(item['name'] == null ? '' : item['name'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown[300],
            )),
        subtitle: Text(item['breed'] == null ? '' : item['breed']),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.brown,
          child: CircleAvatar(
            radius: 26,
            backgroundImage: item['url'] == null
                ? NetworkImage(path_images + 'default_dog.png')
                : NetworkImage(path_images + item['url']),
          ),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    new DogProfile(title: "Dog profile", id: item['id'], refreshData: refreshData, ),
              ));
        },
      ),
    );
  }
}

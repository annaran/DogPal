import 'package:dogwalker2/pages/list_conversation.dart';
import 'package:flutter/material.dart';
import 'package:dogwalker2/api_urls.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dogwalker2/pages/view_dog_calendar.dart';
import 'package:bubble/bubble.dart';

class ViewDogProfile extends StatefulWidget {
  ViewDogProfile({Key key, this.title, @required this.id}) : super(key: key);
  final String title;
  final String id;

  @override
  _ViewDogProfileState createState() => _ViewDogProfileState();
}

class _ViewDogProfileState extends State<ViewDogProfile> {
  String name;
  String location;
  String description;
  String picture;
  String size;
  String breed;
  String ownerid;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
    loadDogData();
  }

  void refreshData() {}

  Future loadDogData() async {
    String url = url_loaddogdata + '?id=' + widget.id;
    print(url);
    Response response = await http.get(url);

    Map data = json.decode(response.body);

    print(data.toString());

    var pic = data['url'] == null
        ? path_images + 'default_dog.png'
        : path_images + data['url'];
    print(pic);

    setState(() {
      name = data['name'];
      location = data['location'];
      description = data['description'];
      size = data['size'];
      breed = data['breed'];
      ownerid = data['owner_id'];
      picture = pic;
    });
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ViewDogCalendar(title: "Dog calendar", id: widget.id),
              ));
        }
        break;

      case 1:
        {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListConversation(
                    title: "Conversation",
                    receiverid: ownerid,
                    refreshData: refreshData),
              ));
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    BubbleStyle styleMe = BubbleStyle(
      nip: BubbleNip.leftTop,
      color: Colors.amber[50],
      margin: BubbleEdges.only(top: 8.0, right: 8.0),
      alignment: Alignment.center,
    );
    return (picture == null)
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: Colors.grey[200],
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              title: Text(widget.title),
              centerTitle: true,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              child: Container(
                  padding: const EdgeInsets.only(
                    left: 30,
                    top: 5,
                    right: 30,
                    bottom: 30,
                  ),
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: CircleAvatar(
                              radius: 73,
                              backgroundColor: Colors.brown,
                              child: CircleAvatar(
                                backgroundColor: Colors.brown.shade800,
                                backgroundImage: NetworkImage('$picture'),
                                radius: 70.0,
                              ),
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "$name" == 'null' ? 'Displayname not set' : "$name",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(children: <Widget>[
                          Expanded(child: Divider()),
                          Text(
                            "Location",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Expanded(child: Divider()),
                        ]),
                      ),
                      Text(
                        "$location" == 'null'
                            ? 'Location not set'
                            : "$location",
                        style: TextStyle(
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(children: <Widget>[
                          Expanded(child: Divider()),
                          Text(
                            "Breed",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Expanded(child: Divider()),
                        ]),
                      ),
                      Text(
                        "$breed" == 'null' ? 'Not set' : "$breed",
                        style: TextStyle(
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(children: <Widget>[
                          Expanded(child: Divider()),
                          Text(
                            "Size",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Expanded(child: Divider()),
                        ]),
                      ),
                      Text(
                        "$size" == 'null' ? 'Not set' : "$size",
                        style: TextStyle(
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(children: <Widget>[
                          Expanded(child: Divider()),
                          Text(
                            "Description",
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          Expanded(child: Divider()),
                        ]),
                      ),
                      Bubble(
                        style: styleMe,
                        child: Text(
                          "$description" == 'null' ? '' : "$description",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'View calendar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  label: 'Message owner',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.amber[800],
              onTap: _onItemTapped,
            ),
          );
  }
}

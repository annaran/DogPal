import 'package:dogwalker2/pages/edit_dog_calendar.dart';
import 'package:flutter/material.dart';
import 'package:dogwalker2/api_urls.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dogwalker2/pages/edit_dog_profile.dart';
import 'package:dogwalker2/pages/edit_photo.dart';
import 'package:bubble/bubble.dart';

class DogProfile extends StatefulWidget {
  DogProfile({Key key, this.title, @required this.id, this.refreshData})
      : super(key: key);
  final String title;
  final String id;
  Function refreshData;

  @override
  _DogProfileState createState() => _DogProfileState();
}

class _DogProfileState extends State<DogProfile> {
  String name;
  String location;
  String description;
  String picture;
  String size;
  String breed;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
    refreshData();
  }

  void refreshData() {
    loadDogData();
  }

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
      picture = pic;
    });
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        {
          Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (context) => new EditDogProfile(
                  title: "Edit dog profile",
                  id: widget.id,
                  refreshData: refreshData,
                ),
              ));
        }
        break;

      case 1:
        {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    EditDogCalendar(title: "Edit dog calendar", id: widget.id),
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
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () async {
                    widget.refreshData();
                    Navigator.pop(context, true);
                  }),
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
                            child: GestureDetector(
                              child: CircleAvatar(
                                radius: 73,
                                backgroundColor: Colors.brown,
                                child: CircleAvatar(
                                  backgroundColor: Colors.brown.shade800,
                                  backgroundImage: NetworkImage('$picture'),
                                  radius: 70.0,
                                  child: Text('Tap to edit'),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditPhoto(
                                        title: widget.title,
                                        dogid: widget.id,
                                        imagetype: 'D',
                                      ),
                                    ));
                              },
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
                  icon: Icon(Icons.edit),
                  label: 'Edit profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Edit calendar',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.amber[800],
              onTap: _onItemTapped,
            ),
          );
  }
}

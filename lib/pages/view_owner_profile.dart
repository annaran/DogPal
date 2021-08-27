import 'package:dogwalker2/pages/list_conversation.dart';
import 'package:dogwalker2/pages/list_reviews.dart';
import 'package:dogwalker2/pages/list_users_dogs.dart';
import 'package:flutter/material.dart';
import 'package:dogwalker2/api_urls.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bubble/bubble.dart';

class ViewOwnerProfile extends StatefulWidget {
  ViewOwnerProfile({Key key, this.title, @required this.id}) : super(key: key);
  final String title;
  final String id;

  @override
  _ViewOwnerProfileState createState() => _ViewOwnerProfileState();
}

class _ViewOwnerProfileState extends State<ViewOwnerProfile> {
  String displayname;
  String location;
  String description;
  String picture;
  int _selectedIndex = 0;
  var pic;

  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
    loadProfileData();
  }

  void refreshData() {}

  Future loadProfileData() async {
    String url = url_loadprofiledata + '?id=' + widget.id;
    print(url);
    Response response = await http.get(url);

    Map data = json.decode(response.body);

    print(data.toString());

    pic = data['picture_id'] == null
        ? path_images + 'default_avatar.png'
        : path_images + data['url'];
    print(pic);

    setState(() {
      displayname = data['displayname'];
      location = data['location'];
      description = data['description'];
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
                  builder: (context) => ListConversation(
                      title: "Conversation",
                      receiverid: widget.id,
                      refreshData: refreshData)));
        }

        break;
      case 1:
        {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ListUsersDogs(title: "Dogs", id: widget.id),
              ));
        }

        break;

      case 2:
        {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ListReviews(title: "Reviews", id: widget.id),
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
                          "$displayname" == 'null'
                              ? 'Displayname not set'
                              : "$displayname",
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
                  icon: Icon(Icons.message),
                  label: 'Send message',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.pets),
                  label: 'View dogs',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.rate_review),
                  label: 'Reviews',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.amber[800],
              onTap: _onItemTapped,
            ),
          );
  }
}

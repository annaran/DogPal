import 'package:dogwalker2/pages/edit_photo.dart';
import 'package:dogwalker2/pages/list_reviews.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dogwalker2/api_urls.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bubble/bubble.dart';

class OwnerProfile extends StatefulWidget {
  OwnerProfile({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _OwnerProfileState createState() => _OwnerProfileState();
}

class _OwnerProfileState extends State<OwnerProfile> {
  SharedPreferences logindata;
  String email;
  String displayname;
  String location;
  String description;
  String picture;
  String userid;
  int _selectedIndex = 0;
  Map data;

  @override
  void initState() {
    super.initState();
    initial();

  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      email = logindata.getString('email');
      userid = logindata.getString('userid');
    });
    loadProfileData();
  }

  Future loadProfileData() async {
    print("load start");
    String url = url_loadprofiledata + '?id=' + userid;
    print(url);
    Response response = await http.get(url);

    data = json.decode(response.body);

    print(data.toString());

    var pic = data['picture_id'] == null
        ? path_images + 'default_avatar.png'
        : path_images + data['url'];
    print(pic);

    setState(() {
      displayname = data['displayname'];
      email = data['email'];
      location = data['location'];
      description = data['description'];
      picture = pic;
    });


  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        {
          Navigator.pushNamed(context, "/editownerprofile");
        }

        break;
      case 1:
        {
          Navigator.pushNamed(context, "/listmydogs");
        }

        break;

      case 2:
        {
          Navigator.pushNamed(context, "/listmessages");
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
            appBar: AppBar(    
              title: Text(widget.title),
              centerTitle: true,
              elevation: 0,
            ),

            drawer: Drawer(
              child: ListView(  
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                    height: 100,
                    child: DrawerHeader(
                      child: Text('DogPal'),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('Change my password'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/editpassword");
                    },
                  ),
                  ListTile(
                    title: Text('My dogs'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/listmydogs");
                    },
                  ),
                  ListTile(
                    title: Text('Browse dogs'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/listdogs");
                    },
                  ),
                  ListTile(
                    title: Text('Browse users'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/listusers");
                    },
                  ),
                  ListTile(
                    title: Text('My reviews'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ListReviews(title: "My reviews", id: userid),
                          ));
                    },
                  ),
                  ListTile(
                    title: Text('My walks'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/listwalks");
                    },
                  ),
                  ListTile(
                    title: Text('Messages'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/listmessages");
                    },
                  ),
                  ListTile(
                    title: Text('Log Out'),
                    onTap: () {
                      logindata.setBool('islogged', false);
                      logindata.remove('userid');
                      logindata.remove('email');
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                  ),
                ],
              ),
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
                                        imagetype: 'U',
                                        dogid: '0',
                                      ),
                                    ));
                              },
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
                  icon: Icon(Icons.edit),
                  label: 'Edit profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.pets),
                  label: 'My dogs',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  label: 'Messages',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.amber[800],
              onTap: _onItemTapped,
            ),
          );
  }
}

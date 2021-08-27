import 'package:dogwalker2/pages/filter_dogs.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dogwalker2/api_urls.dart';
import 'package:http/http.dart';
import 'package:dogwalker2/pages/view_dog_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilteredDogs extends StatefulWidget {
  FilteredDogs(
      {Key key,
      this.title,
      @required this.filteredDogsData,
      @required this.viewType})
      : super(key: key);
  final String title;
  final List filteredDogsData;
  final String viewType;

  @override
  _FilteredDogsState createState() => _FilteredDogsState();
}

class _FilteredDogsState extends State<FilteredDogs> {
  List data;
  SharedPreferences logindata;
  String userid;
  String selectedTimeslot;
  List hiddenTiles;

  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      userid = logindata.getString('userid');
      data = widget.filteredDogsData;
    });
  }

  void _onTapRow(dynamic item) {
    onCalendarUpdate(item);
  }

  void onCalendarUpdate(dynamic item) {
    if (DateTime.parse(item['date'] + ' 23:59:59.000')
        .toUtc()
        .isBefore(DateTime.now().toUtc())) {
      Fluttertoast.showToast(
        msg: 'Cannot update past days',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
      );
    } else {
      updateCalendar(item);
      removeItem(item);
    }
  }

  void removeItem(dynamic item) {
    setState(() {
      data = List.from(data)..remove(item);
    });
  }

  Future updateCalendar(dynamic item) async {
    var url = url_updatecalendar;

    Response response = await http.post(url, body: {
      'dogid': item['dog_id'],
      'date': item['date'],
      'timeslot': item['timeslot_id'],
      'usertype': 'W',
      'id': userid,
      'yesno': '1',
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
    }
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
                          builder: (context) => FilterDogs(title: "Filter")));
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
          return widget.viewType == "dogs"
              ? _buildRowProfiles(data[index])
              : _buildRowTimeslots(data[index]);
        });
  }

  Widget _buildRowProfiles(dynamic item) {
    return Card(
      child: ListTile(
        title: Text(
          item['name'] == null ? '' : item['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.brown[300],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['breed'] == null ? '' : item['breed']),
            Text(item['size'] == null ? '' : item['size']),
            Text(item['location'] == null ? '' : item['location']),
          ],
        ),
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
                    ViewDogProfile(title: "Dog profile", id: item['id']),
              ));
        },
      ),
    );
  }

  Widget _buildRowTimeslots(dynamic item) {
    void _showConfirmationPanel(String timeslotid, String question) {
      showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0)),
          ),
          builder: (context) {
            return Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      question ?? "",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                          color: Colors.green,
                          child: Text(
                            'Yes',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            _onTapRow(item);
                            Navigator.pop(context);
                          }),
                      RaisedButton(
                          color: Colors.red,
                          child: Text(
                            'No',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                          }),
                    ],
                  ),
                ],
              ),
            );
          });
    }

    return Card(
      child: ListTile(
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
        title: Text(
          item['description'] ?? 'Unspecified',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['date'] == null ? '' : item['date']),
            Text(item['name'] == null ? '' : item['name']),
            Text(item['breed'] == null ? '' : item['breed']),
            Text(item['size'] == null ? '' : item['size']),
            Text(item['location'] == null ? '' : item['location']),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              color: Colors.black,
            ),
            Text(
              'Available',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 9,
                color: Colors.black,
              ),
            )
          ],
        ),
        onTap: () {
          _showConfirmationPanel(item['timeslot_id'], "Reserve timeslot?");
        },
      ),
    );
  }
}

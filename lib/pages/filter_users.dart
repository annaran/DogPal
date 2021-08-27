import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:dogwalker2/api_urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'filtered_users.dart';

class FilterUsers extends StatefulWidget {
  FilterUsers({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _FilterUsersState createState() => _FilterUsersState();
}

class _FilterUsersState extends State<FilterUsers> {
  List filtereddata;
  SharedPreferences logindata;
  String userid;
  List selectedListLocations;
  List listOfLocations;
  String selLocations = '';
  String selectedDate;

  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    loadLocations();
    setState(() {
      userid = logindata.getString('userid');
    });
  }

  Future loadLocations() async {
    String url = url_loadlocations;
    print(url);
    Response response = await http.get(url);

    List<dynamic> data = json.decode(response.body);

    print(data.toString());

    setState(() {
      listOfLocations = data;
    });
  }

  Future getFilteredUsersData() async {
    String locations = locationsToString(selectedListLocations) ?? 'null';

    String url =
        url_getfilteredusers + '?userid=' + userid + '&locations=' + locations;
    print(url);
    Response response = await http.get(url);
    filtereddata = jsonDecode(response.body);
    print(filtereddata.toString());

    Navigator.of(context).pop();

    Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => new FilteredUsers(
            title: "Filter results",
            filteredUsersData: filtereddata,
          ),
        ));
  }

  String locationsToString(List selectedListLocations) {
    if (selectedListLocations.length > 0 &&
        selectedListLocations.length != listOfLocations.length) {
      for (var y = 0; y < selectedListLocations.length; y++) {
        selLocations =
            selLocations + '\"' + selectedListLocations[y]['location'] + '\",';
      }
      if (selLocations.endsWith(",")) {
        selLocations = selLocations.substring(0, selLocations.length - 1);
      }
      print(selLocations);
      return selLocations;
    } else
      return null;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return listOfLocations == null
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.title),
              centerTitle: true,
              elevation: 0,
            ),
            body: Container(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 8.0),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: customSearchableDropDown(
                        items: listOfLocations,
                        label: 'Select locations',
                        multiSelectValuesAsWidget: true,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        multiSelect: true,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.search),
                        ),
                        dropDownMenuItems: listOfLocations?.map((item) {
                              return item['location'];
                            })?.toList() ??
                            [],
                        onChanged: (value) {
                          if (value != null) {
                            selectedListLocations = jsonDecode(value);
                          } else {
                            selectedListLocations.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    RaisedButton(
                      onPressed: () {
                        getFilteredUsersData();
                      },
                      child: Text(
                        "Get users",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

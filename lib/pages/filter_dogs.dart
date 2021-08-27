import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:dogwalker2/api_urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'filtered_dogs.dart';

class FilterDogs extends StatefulWidget {
  FilterDogs({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _FilterDogsState createState() => _FilterDogsState();
}

class _FilterDogsState extends State<FilterDogs> {
  CalendarController _calendarController;
  List data;
  List<dynamic> filteredData;
  List<dynamic> filtered_calendardata;
  List timeslots;
  String selectedDate;
  String selectedTimeslot;
  SharedPreferences logindata;
  String userid;
  List selectedListSizes;
  List selectedListLocations;
  List selectedListTimeslots;
  List listOfSizes;
  List listOfLocations;
  List listOfTimeslots;
  String selSizes = '';
  String selTimeslots = '';
  String selLocations = '';

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now().toString().substring(0, 10);
    _calendarController = CalendarController();
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    loadSizes();
    loadLocations();
    loadTimeslots();
    setState(() {
      userid = logindata.getString('userid');
    });
  }

  Future loadSizes() async {
    String url = url_loadsizes;
    print(url);
    Response response = await http.get(url);

    List<dynamic> data = json.decode(response.body);

    print(data.toString());

    setState(() {
      listOfSizes = data;
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

  Future loadTimeslots() async {
    String url = url_timeslots;
    Response response = await http.get(url);

    setState(() {
      listOfTimeslots = jsonDecode(response.body);
    });
    print(data.toString());
  }

  Future getFilteredDogData(String viewType) async {
    String timeslots = timeslotsToString(selectedListTimeslots) ?? 'null';
    String locations = locationsToString(selectedListLocations) ?? 'null';
    String sizes = sizesToString(selectedListSizes) ?? 'null';

    String urlchoice =
        viewType == "dogs" ? url_getfiltereddogs : url_getfilteredtimeslots;

    String url = urlchoice +
        '?userid=' +
        userid +
        '&date=' +
        selectedDate +
        '&timeslots=' +
        timeslots +
        '&locations=' +
        locations +
        '&sizes=' +
        sizes;
    print(url);
    Response response = await http.get(url);

    filteredData = jsonDecode(response.body);

    print(filteredData.toString());

    Navigator.of(context).pop();

    Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => new FilteredDogs(
            title: "Filter results",
            filteredDogsData: filteredData,
            viewType: viewType,
          ),
        ));
  }

  String sizesToString(List selectedListSizes) {
    if (selectedListSizes.length > 0 &&
        selectedListSizes.length != listOfSizes.length) {
      for (var y = 0; y < selectedListSizes.length; y++) {
        selSizes = selSizes + selectedListSizes[y]['id'] + ',';
      }
      if (selSizes.endsWith(",")) {
        selSizes = selSizes.substring(0, selSizes.length - 1);
      }
      print(selSizes);
      return selSizes;
    } else
      return null;
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

  String timeslotsToString(List selectedListTimeslots) {
    if (selectedListTimeslots.length > 0 &&
        selectedListTimeslots.length != listOfTimeslots.length) {
      for (var y = 0; y < selectedListTimeslots.length; y++) {
        selTimeslots = selTimeslots + selectedListTimeslots[y]['id'] + ',';
      }
      if (selTimeslots.endsWith(",")) {
        selTimeslots = selTimeslots.substring(0, selTimeslots.length - 1);
      }
      print(selTimeslots);
      return selTimeslots;
    } else
      return null;
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: null,
      startingDayOfWeek: StartingDayOfWeek.monday,
      initialCalendarFormat: CalendarFormat.week,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: (date, event, _) {
        _onDaySelected(date, event, _);
        print(date);
        setState(() {
          selectedDate = date.toString().substring(0, 10);
        });

        print(selectedDate);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  @override
  Widget build(BuildContext context) {
    return (listOfSizes == null ||
            listOfLocations == null ||
            listOfTimeslots == null)
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
                    _buildTableCalendar(),
                    const SizedBox(height: 8.0),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: customSearchableDropDown(
                        items: listOfSizes,
                        label: 'Select Sizes',
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
                        dropDownMenuItems: listOfSizes?.map((item) {
                              return item['size'];
                            })?.toList() ??
                            [],
                        onChanged: (value) {
                          if (value != null) {
                            selectedListSizes = jsonDecode(value);
                          } else {
                            selectedListSizes.clear();
                          }
                        },
                      ),
                    ),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: customSearchableDropDown(
                        items: listOfTimeslots,
                        label: 'Select Timeslots',
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
                        dropDownMenuItems: listOfTimeslots?.map((item) {
                              return item['description'];
                            })?.toList() ??
                            [],
                        onChanged: (value) {
                          if (value != null) {
                            selectedListTimeslots = jsonDecode(value);
                          } else {
                            selectedListTimeslots.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    RaisedButton(
                      onPressed: () {
                        getFilteredDogData("dogs");
                      },
                      child: Text(
                        "Get dogs",
                      ),
                    ),
                    RaisedButton(
                      onPressed: () {
                        getFilteredDogData("timeslots");
                      },
                      child: Text(
                        "Get timeslots",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

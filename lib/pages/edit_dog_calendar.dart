import 'package:flutter/material.dart';
import 'package:dogwalker2/api_urls.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditDogCalendar extends StatefulWidget {
  EditDogCalendar({Key key, this.title, @required this.id}) : super(key: key);
  final String title;
  final String id;

  @override
  _EditDogCalendarState createState() => _EditDogCalendarState();
}

class _EditDogCalendarState extends State<EditDogCalendar> {
  CalendarController _calendarController;
  List data;
  List<dynamic> calendardata;
  List timeslots;
  String selectedDate;
  String selectedTimeslot;

  void refreshData() {
    getSelectedDogCalendar();
  }

  Future getTimeslotData() async {
    String url = url_timeslots;
    Response response = await http.get(url);

    setState(() {
      data = jsonDecode(response.body);
    });
    print(data.toString());
  }

  Future getSelectedDogCalendar() async {
    String url = url_loadcalendar + '?dogid=' + widget.id;
    Response response = await http.get(url);

    setState(() {
      calendardata = jsonDecode(response.body);
    });

    print(calendardata.toString());
  }

  Color colorizeTimeslots(String timeslot, String date) {
    if (calendardata.length <= 0) {
      print("grey");
      return Colors.grey;
    } else {
      for (var i = 0; i < calendardata.length; i++) {
        print(calendardata[i]['dog_id'].toString());
        if (calendardata[i]['timeslot_id'].toString() == timeslot &&
            calendardata[i]['date'].toString() == date) {
          if (calendardata[i]['status'] == 'A') {
            return Colors.black;
          } else if (calendardata[i]['status'] == 'R') {
            return Colors.yellowAccent[700];
          } else if (calendardata[i]['status'] == 'C') {
            return Colors.green;
          } else {
            print('grey');
            return Colors.grey;
          }
        }
      }
    }
  }

  String getQuestion(String timeslot, String date) {
    if (calendardata.length <= 0) {
      return "Make timeslot available?";
    } else {
      for (var i = 0; i < calendardata.length; i++) {
        if (calendardata[i]['timeslot_id'].toString() == timeslot &&
            calendardata[i]['date'].toString() == date) {
          if (calendardata[i]['status'] == 'A') {
            return "Remove available timeslot?";
          } else if (calendardata[i]['status'] == 'R') {
            return "Accept reservation?";
          } else if (calendardata[i]['status'] == 'C') {
            return "Cancel confirmed reservation?";
          }
        }
      }
    }
  }

  String getStatus(String timeslot, String date) {
    if (calendardata.length <= 0) {
      return "Not set";
    } else {
      for (var i = 0; i < calendardata.length; i++) {
        if (calendardata[i]['timeslot_id'].toString() == timeslot &&
            calendardata[i]['date'].toString() == date) {
          if (calendardata[i]['status'] == 'A') {
            return "Available";
          } else if (calendardata[i]['status'] == 'R') {
            return "Reserved";
          } else if (calendardata[i]['status'] == 'C') {
            return "Confirmed";
          }
        }
      }
    }

    return "Not set";
  }

  void onCalendarUpdate(int yesno) {
    if (DateTime.parse(selectedDate + ' 23:59:59.000')
        .toUtc()
        .isBefore(DateTime.now().toUtc())) {
      Fluttertoast.showToast(
        msg: 'Cannot update past days',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
      );
    } else {
      updateCalendar(yesno);
      refreshData();
    }
  }

  Future updateCalendar(int yesno) async {
    var url = url_updatecalendar;
    print(widget.id);
    print(selectedDate);
    print(selectedTimeslot);

    Response response = await http.post(url, body: {
      'dogid': widget.id,
      'date': selectedDate,
      'timeslot': selectedTimeslot,
      'usertype': 'O',
      'id': '',
      'yesno': yesno.toString(),
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
      refreshData();
    }
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now().toString().substring(0, 10);
    getTimeslotData();
    getSelectedDogCalendar();
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    print('function ondayselected: ' + day.toString());
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  void _onYesNo(String id, int yesno) {
    setState(() {
      selectedTimeslot = id;
    });
    onCalendarUpdate(yesno);
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
        print('build: ' + date.toString());
        setState(() {
          selectedDate = date.toString().substring(0, 10);
        });
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
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
    void _showConfirmationPanel(String id, String question) {
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
                      question ?? "Make timeslot available?",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                          color: Colors.lime[900],
                          child: Text(
                            'Yes',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            _onYesNo(id, 1);
                            Navigator.pop(context);
                          }),
                      RaisedButton(
                          color: Colors.orange[900],
                          child: Text(
                            'No',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (question == "Accept reservation?") {
                              _onYesNo(id, 0);
                            }

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
        title: Text(
          item['description'] ?? 'Unspecified',
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              color: colorizeTimeslots(item['id'], selectedDate),
            ),
            Text(
              getStatus(item['id'], selectedDate),
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 9,
                color: colorizeTimeslots(item['id'], selectedDate),
              ),
            ),
          ],
        ),
        onTap: () {
          _showConfirmationPanel(
              item['id'], getQuestion(item['id'], selectedDate));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          _buildTableCalendar(),
          const SizedBox(height: 8.0),
          Expanded(child: _buildListView()),
        ],
      ),
    );
  }
}

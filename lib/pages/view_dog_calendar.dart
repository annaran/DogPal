import 'package:dogwalker2/api_urls.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class ViewDogCalendar extends StatefulWidget {
  ViewDogCalendar({Key key, this.title, @required this.id}) : super(key: key);
  final String title;
  final String id;

  @override
  _ViewDogCalendarState createState() => _ViewDogCalendarState();
}

class _ViewDogCalendarState extends State<ViewDogCalendar> {
  CalendarController _calendarController;
  List data;
  List<dynamic> calendardata;
  List<dynamic> filtered_calendardata;
  List timeslots;
  String selectedDate;
  String selectedTimeslot;
  SharedPreferences logindata;
  String userid;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now().toString().substring(0, 10);
    _calendarController = CalendarController();
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      userid = logindata.getString('userid');
    });

    getSelectedDogCalendar();
  }

  void refreshData() {
    getSelectedDogCalendar();
  }

  Future getSelectedDogCalendar() async {
    String url =
        url_loadcalendarwalkerview + '?dogid=' + widget.id + '&id=' + userid;
    Response response = await http.get(url);

    setState(() {
      calendardata = jsonDecode(response.body);
    });

    filterCalendardata(selectedDate);   
    print(calendardata.toString());
    
  }

  void filterCalendardata(String date) {
    setState(() {
      filtered_calendardata =
          calendardata.where((x) => x['date'] == date).toList();
      filtered_calendardata.sort((a, b) =>
          int.parse(a['timeslot_id']).compareTo(int.parse(b['timeslot_id'])));
    });
  }

  Color colorizeTimeslots(String status) {
    if (status == 'A') {
      return Colors.black;
    } else if (status == 'R') {
      return Colors.yellowAccent[700];
    } else if (status == 'C') {
      return Colors.green;
    } else
      return Colors.black;

    
  }

  String getStatus(String status) {
    if (status == 'A') {
      return 'Available';
    } else if (status == 'R') {
      return 'Reserved';
    } else if (status == 'C') {
      return 'Confirmed';
    }

    
  }

  String getQuestion(String status) {
    if (status == 'A') {
      return 'Reserve timeslot?';
    } else if (status == 'R') {
      return 'Cancel reservation?';
    } else if (status == 'C') {
      return 'The owner already confirmed this reservation. Cancel anyway?';
    }

    
  }

  void onCalendarUpdate() {
    if (DateTime.parse(selectedDate + ' 23:59:59.000')
        .toUtc()
        .isBefore(DateTime.now().toUtc())) {
      Fluttertoast.showToast(
        msg: 'Cannot update past days',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
      );
    } else {
      updateCalendar();
      refreshData();
      filterCalendardata(selectedDate);
    }
  }

  Future updateCalendar() async {
    var url = url_updatecalendar;

    Response response = await http.post(url, body: {
      'dogid': widget.id,
      'date': selectedDate,
      'timeslot': selectedTimeslot,
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

      refreshData();
      filterCalendardata(selectedDate);
    }
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');

    filterCalendardata(selectedDate);
    print(selectedDate);
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  void _onTapRow(String timeslotid) {
    setState(() {
      selectedTimeslot = timeslotid;
    });

    onCalendarUpdate();
    refreshData();
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
        refreshData();
        filterCalendardata(selectedDate);
        print(selectedDate);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  Widget _buildListView() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount:
            filtered_calendardata == null ? 0 : filtered_calendardata.length,
        itemBuilder: (context, index) {
          return _buildRow(filtered_calendardata[index]);
        });
  }

  Widget _buildRow(dynamic item) {
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
                          color: Colors.lime[900],
                          child: Text(
                            'Yes',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            _onTapRow(timeslotid);

                            Navigator.pop(context);
                          }),
                      RaisedButton(
                          color: Colors.orange[900],
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
        title: Text(
          item['description'] ?? 'Unspecified',
        ),

        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              color: colorizeTimeslots(item['status']),
            ),
            Text(
              getStatus(item['status']),
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 9,
                color: colorizeTimeslots(item['status']),
              ),
            )
          ],
        ),
        onTap: () {
          _showConfirmationPanel(
              item['timeslot_id'], getQuestion(item['status']));
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

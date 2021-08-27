import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dogwalker2/api_urls.dart';

class AddReview extends StatefulWidget {
  AddReview(
      {Key key, this.title, @required this.id, @required this.refreshData})
      : super(key: key);
  final String title;
  final String id;
  final Function refreshData;

  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  SharedPreferences logindata;
  String userid;

  TextEditingController title = TextEditingController();
  TextEditingController review = TextEditingController();
  final _ratingController = TextEditingController();
  double _userRating = 4.5;

  @override
  void initState() {
    super.initState();
    initial();
    _ratingController.text = '4.5';
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      userid = logindata.getString('userid');
    });
  }

  Future addReview() async {
    var url = url_addreview;
    Response response = await http.post(url, body: {
      'ownerid': userid,
      'walkerid': widget.id,
      'title': title.text,
      'rating': _userRating.toString(),
      'review': review.text,
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

      widget.refreshData();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Card(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.pets),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    controller: title,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Review',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    controller: review,
                  ),
                ),
                GFRating(
                  value: _userRating,
                  color: Colors.amber,
                  borderColor: Colors.amber,
                  showTextForm: true,
                  controller: _ratingController,
                  suffixIcon: GFButton(
                    type: GFButtonType.transparent,
                    onPressed: () {
                      setState(() {
                        _userRating =
                            double.parse(_ratingController.text ?? '0.0');
                      });
                    },
                    child: const Text('Rate'),
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    addReview();
                  },
                  child: Text(
                    'Add review',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

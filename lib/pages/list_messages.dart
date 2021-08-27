import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:dogwalker2/api_urls.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dogwalker2/pages/list_conversation.dart';
import 'package:getwidget/getwidget.dart';

class ListMessages extends StatefulWidget {
  ListMessages({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ListMessagesState createState() => _ListMessagesState();
}

class _ListMessagesState extends State<ListMessages> {
  List data;
  SharedPreferences logindata;
  String userid;

  @override
  void initState() {
    super.initState();
    initial();
    print("Init executed)");
  }

  void refreshData() {
    getMessageData();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      userid = logindata.getString('userid');
    });
    getMessageData();
  }

  Future getMessageData() async {
    String url = url_loadmessages + '?id=' + userid;
    Response response = await http.get(url);

    setState(() {
      data = jsonDecode(response.body);
    });
    print(data.toString());
    return "Successfull";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(color: Colors.grey[400], child: _buildListView()),
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
    return Card(
      child: ListTile(
          title: Row(
              children: [
      Text(
        item['sender_id'] == userid ? item['receiver'] : item['sender'],
        textAlign: TextAlign.start,
      ),
       Text(
        item['timestamp'] == null ? '' : item['timestamp'].toString().substring(0,10),
        textAlign: TextAlign.right,
      ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          subtitle: Text(
            item['message'] == null ? '' : item['message'],
            maxLines: 2,
          ),

          onTap: () {
            Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new ListConversation(
              title: "Conversation",
              receiverid: item['sender_id'] == userid
                  ? item['receiver_id']
                  : item['sender_id'],
              refreshData: refreshData)),
            );

          },
        ),
    );
  }
}

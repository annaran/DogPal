import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dogwalker2/api_urls.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bubble/bubble.dart';

class ListConversation extends StatefulWidget {
  ListConversation(
      {Key key, this.title, @required this.receiverid, this.refreshData})
      : super(key: key);
  final String title;
  final String receiverid;
  final Function refreshData;

  @override
  _ListConversationState createState() => _ListConversationState();
}

class _ListConversationState extends State<ListConversation> {
  List data;
  List userdata;
  SharedPreferences logindata;
  String userid;
  TextEditingController message = TextEditingController();
  String displayname = '';

  @override
  void initState() {
    super.initState();
    getDisplaytName();
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      userid = logindata.getString('userid');
    });

    getMessageData();
  }

  Future getDisplaytName() async {
    String url = url_loadprofiledata + '?id=' + widget.receiverid;
    Response response = await http.get(url);
    Map userdata = jsonDecode(response.body);
    setState(() {
      displayname = userdata['displayname'];
    });
  }

  Future sendMessage() async {
    String url = url_sendmessage;
    Response response = await http.post(url, body: {
      "senderid": userid,
      "receiverid": widget.receiverid,
      "message": message.text,
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
      Fluttertoast.showToast(
        msg: 'Send successful',
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.lightGreen,
      );

      message.text = '';
      getMessageData();
    }
  }

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  Future getMessageData() async {
    String url =
        url_loadconversation + '?id=' + userid + '&id2=' + widget.receiverid;
    Response response = await http.get(url);

    setState(() {
      data = jsonDecode(response.body);
    });
    print(data.toString());
  }

  _sendMessageArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: 70,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            iconSize: 25,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              getMessageData();
            },
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
              textCapitalization: TextCapitalization.sentences,
              controller: message,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              sendMessage();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              widget.refreshData();
              Navigator.pop(context, true);
            }),
        title: Text(widget.title + ' (' + displayname + ')'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(children: [
        Expanded(child: _buildListView()),
        _sendMessageArea(),
      ]),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: data == null ? 0 : data.length,
        reverse: true,
        itemBuilder: (context, index) {
          return _buildRow(data[index]);
        });
  }

  Widget _buildRow(dynamic item) {
    BubbleStyle styleMe = BubbleStyle(
      nip: BubbleNip.rightTop,
      color: Color.fromARGB(255, 225, 255, 199),
      margin: BubbleEdges.only(top: 8.0, left: 50.0),
      alignment: Alignment.topRight,
      
    );

    BubbleStyle styleSomebody = BubbleStyle(
      nip: BubbleNip.leftTop,
      color: Colors.white,
      margin: BubbleEdges.only(top: 8.0, right: 50.0),
      alignment: Alignment.topLeft,
    );

    return Bubble(
      style: item['sender_id'] == userid ? styleMe : styleSomebody,
      child: Column(children: [
        Text(item['message'], textAlign: TextAlign.left),
        Text(
          (item['timestamp']),
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[300],
            
          ),
        ),
        
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}

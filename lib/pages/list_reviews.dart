import 'package:flutter/material.dart';
import 'package:dogwalker2/api_urls.dart';
import 'package:getwidget/components/rating/gf_rating.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dogwalker2/pages/add_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListReviews extends StatefulWidget {
  ListReviews({Key key, this.title, @required this.id}) : super(key: key);
  final String title;
  final String id;

  @override
  _ListReviewsState createState() => _ListReviewsState();
}

class _ListReviewsState extends State<ListReviews> {
  List data;
  SharedPreferences logindata;
  String userid;

  @override
  void initState() {
    super.initState();

    initial();
    refreshData();
  }

  void initial() async {
 
    logindata = await SharedPreferences.getInstance();
    setState(() {
      userid = logindata.getString('userid');
    });

  }

  void refreshData() {
    getReviewData();
  }

  Future getReviewData() async {
    String url = url_listreviews + '?id=' + widget.id;
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
      floatingActionButton: (userid == widget.id)
          ? Container()
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddReview(
                        title: "Add review",
                        id: widget.id,
                        refreshData: refreshData,
                      ),
                    ));
              },
              label: Text('Add'),
              icon: Icon(Icons.rate_review),            
            ),
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.brown,
              child: CircleAvatar(
                radius: 26,
                backgroundImage: item['url'] == null
                    ? NetworkImage(path_images + 'default_avatar.png')
                    : NetworkImage(path_images + item['url']),
              ),
            ),
            title: Text(
              item['title'],
              style: TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "by " + item['displayname'],
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              item['review'],
              style: TextStyle(
                color: Colors.black.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GFRating(
                  color: Colors.amber,
                  borderColor: Colors.amber,
                  value: double.parse(item['rating']),
                  size: GFSize.SMALL,
                ),
                Text(
                  item['date'].toString().substring(0, 10),
                  style: TextStyle(color: Colors.brown[200]),
                )
              ],
            ),
          ),
     
        ],
      ),
    );
  }
}

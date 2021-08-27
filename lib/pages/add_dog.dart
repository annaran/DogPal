import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dogwalker2/api_urls.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddDog extends StatefulWidget {
  AddDog({Key key, this.title, this.refreshData}) : super(key: key);
  final String title;
  final Function refreshData;

  @override
  _AddDogState createState() => _AddDogState();
}

class _AddDogState extends State<AddDog> {
  SharedPreferences logindata;
  String userid;
  String dogid;
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  var selectedSize;
  var selectedBreed;
  List listOfSizes;
  List listOfBreeds;

  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
    loadSizes();
    loadBreeds();
    logindata = await SharedPreferences.getInstance();
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

  Future loadBreeds() async {
    String url = url_loadbreeds;
    print(url);
    Response response = await http.get(url);

    List<dynamic> data = json.decode(response.body);
    print(data.toString());

    setState(() {
      listOfBreeds = data;
    });
  }

  Future addDog(String selectedSize, String selectedBreed) async {
    var url = url_adddog;
    Response response = await http.post(url, body: {
      'id': userid,
      'name': name.text,
      'size': selectedSize,
      'breed': selectedBreed,
      'description': description.text,
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
      print(data['dogid']);
      widget.refreshData();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return (listOfSizes == null || listOfBreeds == null)
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
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
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.pets),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          controller: name,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          controller: description,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: customSearchableDropDown(
                          items: listOfSizes,
                          label: 'Select Size',
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                              selectedSize = value['id'].toString();
                            } else {
                              selectedSize = null;
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: customSearchableDropDown(
                          items: listOfBreeds,
                          label: 'Select breed',
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.search),
                          ),
                          dropDownMenuItems: listOfBreeds?.map((item) {
                                return item['breed'];
                              })?.toList() ??
                              [],
                          onChanged: (value) {
                            if (value != null) {
                              selectedBreed = value['id'].toString();
                            } else {
                              selectedBreed = null;
                            }
                          },
                        ),
                      ),
                      RaisedButton(
                        onPressed: () {
                          addDog(selectedSize, selectedBreed);
                        },
                        child: Text(
                          'Add dog',
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

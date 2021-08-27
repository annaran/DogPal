import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dogwalker2/api_urls.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';

class EditDogProfile extends StatefulWidget {
  EditDogProfile({Key key, this.title, @required this.id, this.refreshData})
      : super(key: key);
  final String title;
  final String id;
  final Function refreshData;

  @override
  _EditDogProfileState createState() => _EditDogProfileState();
}

class _EditDogProfileState extends State<EditDogProfile> {
  SharedPreferences logindata;
  String userid;
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();

  var selectedSize;
  var selectedBreed;
  var initialSize;
  var initialBreed;
  List listOfSizes;
  List listOfBreeds;

  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      userid = logindata.getString('userid');
    });

    loadSizes();
    loadBreeds();
    loadDogProfileData();
  }

  Future updateDogProfile(String selectedSize, String selectedBreed) async {
    print("initial breed: " + initialBreed);
    print("initial size: " + initialSize);
    print("selected breed: " + selectedBreed);
    print("selected size: " + selectedSize);
    var url = url_updatedogprofiledata;
    Response response = await http.post(url, body: {
      'id': widget.id,
      'name': name.text,
      'description': description.text,
      'size_id': selectedSize,
      'breed_id': selectedBreed
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

  Future loadDogProfileData() async {
    String url = url_loaddogdata + '?id=' + widget.id;
    print(url);
    Response response = await http.get(url);

    Map data = json.decode(response.body);
    print(data.toString());

    // initializing text controller with values from db
    name.text = data['name'];
    initialSize = data['size_id'];
    initialBreed = data['breed_id'];
    description.text = data['description'];
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

  @override
  Widget build(BuildContext context) {
    return (listOfSizes == null || listOfBreeds == null)
        ? Center(child: CircularProgressIndicator())
        :
    Scaffold(
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
                        
                        selectedSize = initialSize;
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
                        
                        selectedBreed = initialBreed;
                      }
                    },
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                    updateDogProfile(selectedSize ?? initialSize, selectedBreed ?? initialBreed);
                  },
                  child: Text(
                    'Update',
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

import 'package:dogwalker2/pages/dog_profile.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dogwalker2/api_urls.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditPhoto extends StatefulWidget {
  EditPhoto({Key key, this.title, @required this.imagetype, this.dogid})
      : super(key: key);
  final String title;
  final String imagetype;
  final String dogid;

  @override
  _EditPhotoState createState() => _EditPhotoState();
}

class _EditPhotoState extends State<EditPhoto> {
  SharedPreferences logindata;
  File _image;
  final picker = ImagePicker();
  TextEditingController nameController = TextEditingController();
  String picture;
  String userid;

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
    loadPictureData();
  }

  Future choiceImage() async {
    var pickedImage = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedImage.path);
    });
  }

  Future uploadImage() async {
    final uri = Uri.parse(url_uploadimage);
    var request = http.MultipartRequest('POST', uri);
    request.fields['id'] = userid;
    request.fields['imagetype'] = widget.imagetype;
    request.fields['dogid'] = widget.dogid;
    var pic = await http.MultipartFile.fromPath("image", _image.path);
    request.files.add(pic);
    var response = await request.send();

    var responseString = await response.stream.bytesToString();
    Map data = json.decode(responseString);

    if (response.statusCode == 200) {
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
        Navigator.of(context).pop();
        if (widget.imagetype == 'U') {
          Navigator.pushReplacementNamed(context, "/ownerprofile");
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DogProfile(title: "Dog profile", id: widget.dogid),
              ));
        }
      }
    } else {
      print('Image Not Uploded');

      print(responseString);
    }
  }

  Future loadPictureData() async {
    print("load start");

    print(url_loadpicturedata);
    String url = url_loadpicturedata +
        '?id=' +
        userid +
        '&dogid=' +
        widget.dogid +
        '&imagetype=' +
        widget.imagetype;
    print(url);
    Response response = await http.get(url);

    Map data = json.decode(response.body);

    print(data.toString());

    var defimg =
        widget.imagetype == "U" ? 'default_avatar.png' : 'default_dog.png';

    var pic = data['picture_id'] == null
        ? path_images + defimg
        : path_images + data['url'];
    print(pic);

    setState(() {
      picture = pic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (picture == null)
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              title: Text(widget.title),
              centerTitle: true,
              elevation: 0,
            ),
            body: Container(
                child: Column(
              children: <Widget>[
                Center(
                  child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.brown.shade800,
                        backgroundImage: _image == null
                            ? NetworkImage('$picture')
                            : FileImage(File(_image.path)),
                        radius: 70.0,
                      )
                      ),
                ),
                IconButton(
                  icon: Icon(Icons.camera),
                  onPressed: () {
                    choiceImage();
                  },
                ),
                RaisedButton(
                  child: Text('Upload Image'),
                  onPressed: () {
                    uploadImage();
                  },
                ),
              ],
            )));
  }
}

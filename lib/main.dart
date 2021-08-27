import 'package:dogwalker2/pages/edit_password.dart';
import 'package:dogwalker2/pages/owner_profile.dart';
import 'package:dogwalker2/pages/edit_owner_profile.dart';
import 'package:dogwalker2/pages/list_dogs.dart';
import 'package:dogwalker2/pages/list_my_dogs.dart';
import 'package:dogwalker2/pages/list_users.dart';
import 'package:dogwalker2/pages/list_walks.dart';
import 'package:dogwalker2/pages/list_messages.dart';
import 'package:flutter/material.dart';
import 'package:dogwalker2/pages/start.dart';
import 'package:dogwalker2/pages/login.dart';
import 'package:dogwalker2/pages/register.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'DogPal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.brown,
            accentColor: Colors.brown,
            textTheme: TextTheme(bodyText2: TextStyle(color: Colors.black54)),
            scaffoldBackgroundColor: Colors.blueGrey[50],
            buttonTheme: ButtonThemeData(
              buttonColor: Colors.amber,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              textTheme: ButtonTextTheme.accent,
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              foregroundColor: Colors.brown,
              backgroundColor: Colors.amber,
              )
            ),
        //home: '/',
        initialRoute: '/',
        routes: {
          '/': (context) => Start(),          
          '/login': (context) => Login(title: 'Login'),
          '/register': (context) => Register(title: 'Register'),
          '/ownerprofile': (context) => OwnerProfile(title: 'My profile'),
          '/editownerprofile': (context) =>
              EditOwnerProfile(title: 'Edit my profile'),
          '/listmessages': (context) => ListMessages(title: 'Messages'),
          '/listdogs': (context) => ListDogs(title: 'Dogs'),
          '/listmydogs': (context) => ListMyDogs(title: 'My dogs'), 
          '/listwalks': (context) => ListWalks(title: 'Walks'),
          '/editpassword': (context) => EditPassword(title: 'Change password'),
          '/listusers': (context) => ListUsers(title: 'Users'),
        });
  }
}

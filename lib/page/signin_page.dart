import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ungfirebasefood/page/rider_service.dart';
import 'package:ungfirebasefood/page/shop_service.dart';
import 'package:ungfirebasefood/page/user_service.dart';
import 'package:ungfirebasefood/utility/normal_dialog.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String email, password;

  Container emailForm() => Container(
        margin: EdgeInsets.only(top: 16.0),
        width: 250.0,
        child: TextField(
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => email = value.trim(),
          decoration: InputDecoration(
            labelText: 'Email :',
            border: OutlineInputBorder(),
          ),
        ),
      );

  Container passwordForm() => Container(
        margin: EdgeInsets.only(top: 16.0),
        width: 250.0,
        child: TextField(
          obscureText: true,
          onChanged: (value) => password = value.trim(),
          decoration: InputDecoration(
            labelText: 'Password :',
            border: OutlineInputBorder(),
          ),
        ),
      );

  Container showLogo() => Container(
        margin: EdgeInsets.only(top: 16.0),
        height: 130.0,
        child: Image.asset('images/logo.png'),
      );

  Future<Null> authenFirebase() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      String uid = value.user.uid;
      Firestore firestore = Firestore.instance;
      CollectionReference collectionReference = firestore.collection('User');
      await collectionReference.document(uid).snapshots().listen((event) {
        String typeUser = event.data['TypeUser'];
        if (typeUser == 'User') {
          routeToService(UserService());
        } else if (typeUser == 'Shop') {
          routeToService(ShopService());
        } else {
          routeToService(RiderService());
        }
      });
    }).catchError((value) {
      String string = value.message;
      normalDialog(context, string);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (email == null ||
              email.isEmpty ||
              password == null ||
              password.isEmpty) {
            normalDialog(context, 'Have Space');
          } else {
            authenFirebase();
          }
        },
        child: Icon(Icons.navigate_next),
      ),
      appBar: AppBar(
        title: Text('ลงชื่อเข้าใช้งาน'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            showLogo(),
            emailForm(),
            passwordForm(),
          ],
        ),
      ),
    );
  }

  void routeToService(Widget widget) {
    MaterialPageRoute materialPageRoute = MaterialPageRoute(
      builder: (context) => widget,
    );
    Navigator.pushAndRemoveUntil(context, materialPageRoute, (route) => false);
  }
}

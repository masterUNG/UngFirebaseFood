import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ungfirebasefood/page/rider_service.dart';
import 'package:ungfirebasefood/page/shop_service.dart';
import 'package:ungfirebasefood/page/user_service.dart';
import 'package:ungfirebasefood/utility/normal_dialog.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String typeUser, name, email, password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (name == null ||
              name.isEmpty ||
              email == null ||
              email.isEmpty ||
              password == null ||
              password.isEmpty) {
            normalDialog(context, 'กรุณากรอกทุกช่อง คะ');
          } else if (typeUser == null) {
            normalDialog(context, 'กรุณาเลือก ชนิดของสมาชิก ด้วย คะ');
          } else {
            registerThread();
          }
        },
        child: Icon(Icons.cloud_upload),
      ),
      appBar: AppBar(
        title: Text('สมัครสมาชิก'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              showLogo(),
              nameForm(),
              emailForm(),
              passwordForm(),
              userRadio(),
              shopRadio(),
              riderRadio(),
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> registerThread() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      String uid = value.user.uid;

      updataData(uid);
    }).catchError((value) {
      String string = value.message;
      normalDialog(context, string);
    });
  }

  Future updataData(String uid) async {
    Firestore firestore = Firestore.instance;
    CollectionReference collectionReference = firestore.collection('User');

    Map<String, dynamic> map = Map();
    map['Name'] = name;
    map['TypeUser'] = typeUser;

    await collectionReference.document(uid).setData(map).then((value) {
      if (typeUser == 'User') {
        routeToService(UserService());
      } else if (typeUser == 'Shop') {
        routeToService(ShopService());
      } else {
        routeToService(RiderService());
      }
    });
  }

  void routeToService(Widget widget) {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => widget,
    );
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  Widget userRadio() => Container(
        width: 200.0,
        child: Row(
          children: <Widget>[
            Radio(
              value: 'User',
              groupValue: typeUser,
              onChanged: (value) {
                setState(() {
                  typeUser = value;
                });
              },
            ),
            Text('ผู้ซื้อ'),
          ],
        ),
      );

  Widget shopRadio() => Container(
        width: 200.0,
        child: Row(
          children: <Widget>[
            Radio(
              value: 'Shop',
              groupValue: typeUser,
              onChanged: (value) {
                setState(() {
                  typeUser = value;
                });
              },
            ),
            Text('ร้านค้า'),
          ],
        ),
      );

  Widget riderRadio() => Container(
        width: 200.0,
        child: Row(
          children: <Widget>[
            Radio(
              value: 'Rider',
              groupValue: typeUser,
              onChanged: (value) {
                setState(() {
                  typeUser = value;
                });
              },
            ),
            Text('ผู้ส่ง'),
          ],
        ),
      );

  Container nameForm() => Container(
        margin: EdgeInsets.only(top: 16.0),
        width: 250.0,
        child: TextField(
          onChanged: (value) => name = value.trim(),
          decoration: InputDecoration(
            labelText: 'Name :',
            border: OutlineInputBorder(),
          ),
        ),
      );

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
}

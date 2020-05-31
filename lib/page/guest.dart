import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ungfirebasefood/page/rider_service.dart';
import 'package:ungfirebasefood/page/shop_service.dart';
import 'package:ungfirebasefood/page/signin_page.dart';
import 'package:ungfirebasefood/page/signup_page.dart';
import 'package:ungfirebasefood/page/user_service.dart';

class Guest extends StatefulWidget {
  @override
  _GuestState createState() => _GuestState();
}

class _GuestState extends State<Guest> {




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  Future<Null> checkLogin()async{
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await firebaseAuth.currentUser();
    if (firebaseUser != null) {
      String uid = firebaseUser.uid;
      findTypeUser(uid);
    }
  }

  Future<Null> findTypeUser(String string)async{
    Firestore firestore = Firestore.instance;
    CollectionReference collectionReference = firestore.collection('User');
    await collectionReference.document(string).snapshots().listen((event) { 
      String typeUser = event.data['TypeUser'];
      print('typeUser Current Login ==>> $typeUser');
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
    MaterialPageRoute route = MaterialPageRoute(builder: (context) => widget,);
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guest'),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('Name'),
              accountEmail: Text('Email'),
            ),
            signInMenu(),
            signUpMenu(),
          ],
        ),
      ),
    );
  }

  ListTile signInMenu() => ListTile(
        onTap: () {
          Navigator.pop(context);
          routeToWidget(SignInPage());
        },
        leading: Icon(Icons.account_box),
        title: Text('ลงชื่อเข้าใช้งาน'),
      );

  ListTile signUpMenu() => ListTile(
        onTap: () {
          Navigator.pop(context);
          routeToWidget(SignUpPage());
        },
        leading: Icon(Icons.assignment),
        title: Text('สมัครสมาชิก'),
      );

  void routeToWidget(Widget widget) {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => widget,
    );
    Navigator.push(context, route);
  }
}

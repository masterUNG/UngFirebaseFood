import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'guest.dart';

class UserService extends StatefulWidget {
  @override
  _UserServiceState createState() => _UserServiceState();
}

class _UserServiceState extends State<UserService> {
  List<String> nameShops = List();
  List<String> uidShops = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readAllShop();
  }

  Future<Null> readAllShop() async {
    Firestore firestore = Firestore.instance;
    CollectionReference reference = firestore.collection('User');
    await reference.snapshots().listen((event) {
      for (var snapshot in event.documents) {
        if (snapshot.data['TypeUser'] == 'Shop') {
          nameShops.add(snapshot.data['Name']);
          print('nameShop = ${snapshot.data['Name']}');

          String uidShop = snapshot.documentID;
          print('uidShop = $uidShop');
        }
      }
    });
  }

  ListTile signOutMenu() => ListTile(
        leading: Icon(Icons.exit_to_app),
        title: Text('Sign Out'),
        onTap: () {
          Navigator.pop(context);
          signOutProcess();
        },
      );

  Future<Null> signOutProcess() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth.signOut().then((value) {
      MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => Guest(),
      );
      Navigator.pushAndRemoveUntil(context, route, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('Name'),
              accountEmail: Text('Login'),
            ),
            signOutMenu(),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('User Service'),
      ),
    );
  }
}

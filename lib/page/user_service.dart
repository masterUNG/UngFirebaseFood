import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  Future<Null> readAllShop()async{

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Service'),),
    );
  }
}
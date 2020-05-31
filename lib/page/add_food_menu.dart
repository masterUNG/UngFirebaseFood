import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ungfirebasefood/utility/normal_dialog.dart';

class AddFoodMenu extends StatefulWidget {
  @override
  _AddFoodMenuState createState() => _AddFoodMenuState();
}

class _AddFoodMenuState extends State<AddFoodMenu> {
  File file;
  String name, price, detail, urlPic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มเมนู อาหาร'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            imageGroup(),
            nameForm(),
            priceForm(),
            detailForm(),
            saveButton()
          ],
        ),
      ),
    );
  }

  Widget saveButton() {
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      width: 250.0,
      child: RaisedButton(
        onPressed: () {
          if (file == null) {
            normalDialog(context, 'กรุณาเลือก รูปภาพด้วย คะ');
          } else if (name == null ||
              name.isEmpty ||
              price == null ||
              price.isEmpty ||
              detail == null ||
              detail.isEmpty) {
            normalDialog(context, 'กรุณากรอก ทุกช่อง คะ');
          } else {
            uploadPicture();
          }
        },
        child: Text('Save Food Menu'),
      ),
    );
  }

  Future<Null> uploadPicture() async {
    Random random = Random();
    int i = random.nextInt(100000);
    String namePic = 'food$i.jpg';

    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    StorageReference storageReference =
        firebaseStorage.ref().child('MenuFood/$namePic');
    StorageUploadTask storageUploadTask = storageReference.putFile(file);
    await (await storageUploadTask.onComplete)
        .ref
        .getDownloadURL()
        .then((value) {
      urlPic = value;
      print('urlPic = $urlPic');
      insertMenu();
    });
  }

  Future<Null> insertMenu() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await auth.currentUser();
    String uidShop = firebaseUser.uid;

    Map<String, dynamic> map = Map();
    map['Name'] = name;
    map['Detail'] = detail;
    map['Price'] = price;
    map['UrlPic'] = urlPic;
    map['UidShop'] = uidShop;

    Firestore firestore = Firestore.instance;
    CollectionReference collectionReference = firestore.collection('MenuFood');
    await collectionReference
        .document()
        .setData(map)
        .then((value) => Navigator.pop(context));
  }

  Widget nameForm() => Container(
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

  Widget priceForm() => Container(
        margin: EdgeInsets.only(top: 16.0),
        width: 250.0,
        child: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) => price = value.trim(),
          decoration: InputDecoration(
            labelText: 'Price :',
            border: OutlineInputBorder(),
          ),
        ),
      );

  Widget detailForm() => Container(
        margin: EdgeInsets.only(top: 16.0),
        width: 250.0,
        child: TextField(
          onChanged: (value) => detail = value.trim(),
          decoration: InputDecoration(
            labelText: 'Detail :',
            border: OutlineInputBorder(),
          ),
        ),
      );

  Future<Null> chooseImage(ImageSource imageSource) async {
    var object = await ImagePicker().getImage(
      source: imageSource,
      maxWidth: 800.0,
      maxHeight: 800.0,
    );
    setState(() {
      file = File(object.path);
    });
  }

  Row imageGroup() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () => chooseImage(ImageSource.camera),
          ),
          Container(
            width: 250.0,
            height: 250.0,
            child:
                file == null ? Image.asset('images/pic.png') : Image.file(file),
          ),
          IconButton(
            icon: Icon(Icons.add_photo_alternate),
            onPressed: () => chooseImage(ImageSource.gallery),
          ),
        ],
      );
}

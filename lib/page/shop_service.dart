import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ungfirebasefood/page/add_food_menu.dart';
import 'package:ungfirebasefood/page/guest.dart';

class ShopService extends StatefulWidget {
  @override
  _ShopServiceState createState() => _ShopServiceState();
}

class _ShopServiceState extends State<ShopService> {
  List<String> names = List();
  List<String> details = List();
  List<String> prices = List();
  List<String> urlPics = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readMenuFood();
  }

  Future<Null> readMenuFood() async {

    if (names.length != 0) {
      names.clear();
      details.clear();
      prices.clear();
      urlPics.clear();
    }


    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser firebaseUser = await auth.currentUser();
    String loginUidShop = firebaseUser.uid;

    Firestore firestore = Firestore.instance;
    CollectionReference reference = firestore.collection('MenuFood');
    await reference.snapshots().listen((event) {
      for (var snapshot in event.documents) {
        String uidShop = snapshot.data['UidShop'];
        if (loginUidShop == uidShop) {
          setState(() {
            names.add(snapshot.data['Name']);
            details.add(snapshot.data['Detail']);
            prices.add(snapshot.data['Price']);
            urlPics.add(snapshot.data['UrlPic']);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: names.length == 0
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: names.length,
              itemBuilder: (context, index) => showContent(index),
            ),
      floatingActionButton: addNewMenu(),
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
        title: Text('Shop Service'),
      ),
    );
  }

  Widget showContent(int index) => Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.4,
            child: Image.network(
              urlPics[index],
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.width * 0.4,
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      names[index],
                      style: TextStyle(
                        fontSize: 24.0,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      prices[index],
                      style: TextStyle(
                        fontSize: 30.0,
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(details[index]),
                  ],
                ),
              ],
            ),
          ),
        ],
      );

  FloatingActionButton addNewMenu() => FloatingActionButton(
        onPressed: () {
          MaterialPageRoute route = MaterialPageRoute(
            builder: (context) => AddFoodMenu(),
          );
          Navigator.push(context, route).then((value) => readMenuFood());
        },
        child: Icon(Icons.add),
      );

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
}

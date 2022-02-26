import 'package:biniyog/views/styles/k_colors.dart';
import 'package:biniyog/views/styles/k_text_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'add_item_screen.dart';
import 'ItemDetails.dart';
import '../../models/Posts.dart';
import 'home_page.dart';

class UsersItem extends StatefulWidget {
  final String currentuserId = null;

  @override
  _UsersItemState createState() => _UsersItemState();
}

class _UsersItemState extends State<UsersItem> {
  List<KPostsModel> postsList = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseRef = FirebaseDatabase.instance.reference().child("User");
  FirebaseStorage storage = FirebaseStorage.instance;
  User user;

  bool isLogged = false;
  final Future<FirebaseApp> _future = Firebase.initializeApp();

  checkAuthentication() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("start");
      }
    });
  }

  getUser() async {
    User firebaseUser = _auth.currentUser;
    await firebaseUser?.reload();
    firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser;
        this.isLogged = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
    this.getUser();
    DatabaseReference postsRef =
        FirebaseDatabase.instance.reference().child("User");
    final String currentUserId = _auth.currentUser.uid;

    postsRef.once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var data = snap.value;

      postsList.clear();

      for (var uniqueKey in keys) {
        KPostsModel posts = new KPostsModel(
            data[uniqueKey]['Name'],
            data[uniqueKey]['Description'],
            data[uniqueKey]['Minimum_Bid_Price'],
            data[uniqueKey]['ImageURL'],
            data[uniqueKey]['End_Date'],
            data[uniqueKey]['AuctionID']);

        print(currentUserId);
        if (data[uniqueKey]['UserID'] == currentUserId) {
          postsList.add(posts);
        }
      }

      setState(() {
        print('Length : $postsList.length');
      });
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              size: 30,
              color: Colors.black,
            )),
        titleSpacing: 0.0,
        title: Text(
          "My Items",
          style: KTextStyle.headline2.copyWith(color: Colors.black),
        ),
      ),
      body: new Container(
        child: postsList.length == 0
            ? new Text("")
            : new ListView.builder(
                itemCount: postsList.length,
                itemBuilder: (_, index) {
                  return PostUI(
                      index,
                      postsList[index].imgUrl,
                      postsList[index].description,
                      postsList[index].endDate,
                      postsList[index].minimumBidPrice,
                      postsList[index].name,
                      postsList[index].auctionId);
                }),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: KColor.primary,
        onPressed: () {
          debugPrint("Form button clicked");
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AddItemScreen();
          }));
        },
      ),
    );
  }

  Widget PostUI(int index, String image, String description, String date,
      String minBid, String name, String auctionID) {
    return new GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetails(),
              settings: RouteSettings(
                arguments: postsList[index],
              ),
            ),
          );
        },
        child: Card(
          elevation: 10.0,
          margin: EdgeInsets.all(15.0),
          child: new Container(
            padding: new EdgeInsets.all(14.0),
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(
                        name,
                        style: Theme.of(context).textTheme.subtitle1,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  new Image.network(image, fit: BoxFit.cover),
                  SizedBox(
                    height: 10.0,
                  ),
                ]),
          ),
        ));
  }
}

import 'package:biniyog/services/navigation_service.dart';
import 'package:biniyog/views/global_components/k_post_card.dart';
import 'package:biniyog/views/styles/k_colors.dart';
import 'package:biniyog/views/styles/k_text_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'add_item_screen.dart';
import 'item_details_screen.dart';
import '../../models/Posts.dart';
import 'user_items_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<KPostsModel> postsList = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseRef = FirebaseDatabase.instance.reference().child("User");
  FirebaseStorage storage = FirebaseStorage.instance;
  User user;
  bool isLogged = false;

  checkAuthentication() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("start");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
    this.getUser();
    DatabaseReference postsRef =
        FirebaseDatabase.instance.reference().child("User");
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

        postsList.add(posts);
      }

      setState(() {
        print('Length : ${postsList.length}');
      });
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

  signOut() async {
    _auth.signOut();

    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(

        child: ListView(
          children: [
            Container(

              padding: EdgeInsets.all(20),
              width: double.infinity,
              color: KColor.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  Text(_auth.currentUser.displayName,style: KTextStyle.headline2,),
                  Text(_auth.currentUser.email,style: KTextStyle.headline3)
                ],
              ),
            ),
            ListTile(
              onTap: (){
                Navigator.push(context, FadeRoute(page: UserItemsScreen()));
              },
              leading: Icon(Icons.add_shopping_cart),
              title: Text("My Items"),
            ),
            ListTile(
              onTap: (){
                signOut();
              },
              leading: Icon(Icons.logout),
              title: Text("Log Out"),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: KColor.primary,
        centerTitle: true,
        title: Text('Auction App'),
      ),
      body:  ListView.builder(
        itemCount: postsList.length,
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (context,index){
          return KPostCard(onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailsScreen(),
                settings: RouteSettings(
                  arguments: postsList[index],
                ),
              ),
            );
          },
          image: postsList[index].imgUrl,
            name: postsList[index].minimumBidPrice,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: KColor.primary,
        onPressed: () {
          debugPrint("Form button clicked");
          Navigator.push(context, FadeRoute(page: AddItemScreen()));
        },
      ),
    );
  }


}



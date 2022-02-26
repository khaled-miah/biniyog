import 'package:biniyog/views/global_components/k_button.dart';
import 'package:biniyog/views/styles/k_text_style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/Bids.dart';
import 'home_page.dart';
import '../../models/Posts.dart';
import 'user_items_screen.dart';

class ItemDetailsScreen extends StatefulWidget {
  @override
  _ItemDetailsScreenState createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  List<Bids> bidsList = [];
  final bid = TextEditingController();
  String postAuctionId;
  int flag = 0;
  int winner = 0;
  String _bidWinner = "No bidder yet";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseRef = FirebaseDatabase.instance.reference().child("User");
  final DatabaseReference bidsRef =
      FirebaseDatabase.instance.reference().child("Bid");
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

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
    this.getUser();

    bidsRef.once().then((DataSnapshot snap) {
      var keys = snap.value.keys;
      var data = snap.value;

      bidsList.clear();

      for (var uniqueKey in keys) {
        Bids bids = new Bids(
          data[uniqueKey]['AuctionID'],
          data[uniqueKey]['User_name'],
          data[uniqueKey]['Bid'],
          data[uniqueKey]['UserID'],
        );

        final KPostsModel todo = ModalRoute.of(context).settings.arguments;
        postAuctionId = todo.auctionId;

        if (data[uniqueKey]['AuctionID'] == postAuctionId) {
          int initValue = int.parse(data[uniqueKey]['Bid']);

          if (initValue > winner) {
            _bidWinner = data[uniqueKey]['User_name'];
            winner = initValue;
          }
          bidsList.add(bids);
        }
        print(_bidWinner);
      }

      setState(() {
        print('Length : ${bidsList.length}');
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

  void addBid(String bid) {
    final KPostsModel todo = ModalRoute.of(context).settings.arguments;
    if (flag == 0) {
      bidsRef.push().set({
        'Bid': bid,
        'User_name': user.displayName,
        'AuctionID': todo.auctionId,
        'UserID': user.uid
      });
    } else {
      bidsRef.once().then((DataSnapshot snap) {
        var KEYS = snap.value.keys;
        var DATA = snap.value;

        for (var individualKey in KEYS) {
          Bids bids = new Bids(
            DATA[individualKey]['AuctionID'],
            DATA[individualKey]['User_name'],
            DATA[individualKey]['Bid'],
            DATA[individualKey]['UserID'],
          );

          if (DATA[individualKey]['UserID'] == user.uid &&
              DATA[individualKey]['AuctionID'] == todo.auctionId) {
            String key = individualKey;
            print("key:$key");

            bidsRef.child(key).remove();

            bidsRef.child(key).set({
              'Bid': bid,
              'User_name': user.displayName,
              'AuctionID': todo.auctionId,
              'UserID': user.uid
            });
          }
        }
      });
    }

    refresh();
  }

  void refresh() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return new HomePage();
    }));
  }

  void _showDialog(String txt) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Sorry!!"),
          content: new Text(txt),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool isNumber(String string) {
    // Null or empty string is not a number
    if (string == null || string.isEmpty) {
      return false;
    }
    final number = num.tryParse(string);

    if (number == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final KPostsModel todo = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        resizeToAvoidBottomInset: false,
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
            "Item Details",
            style: KTextStyle.headline2.copyWith(color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Image.network(
                              todo.imgUrl,
                              height: 300.0,
                              width: 300.0,
                              alignment: Alignment.center,
                            ),
                          ),

                          //child: Text("For",style: TextStyle(color:Colors.black,fontSize:25),),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ]),
              ),
              Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            "Name: ",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          //child: Text("Geeks",style: TextStyle(color:Colors.black,fontSize:25),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            todo.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          //child: Text("For",style: TextStyle(color:Colors.black,fontSize:25),),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ]),
              ),
              Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            "Description: ",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          //child: Text("Geeks",style: TextStyle(color:Colors.black,fontSize:25),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            todo.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          //child: Text("For",style: TextStyle(color:Colors.black,fontSize:25),),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ]),
              ),
              Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            "Minimum Bid Price: ",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          //child: Text("Geeks",style: TextStyle(color:Colors.black,fontSize:25),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            "${todo.minimumBidPrice} Taka",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          //child: Text("For",style: TextStyle(color:Colors.black,fontSize:25),),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ]),
              ),
              Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            "End Date: ",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          //child: Text("Geeks",style: TextStyle(color:Colors.black,fontSize:25),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            todo.endDate,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          //child: Text("For",style: TextStyle(color:Colors.black,fontSize:25),),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ]),
              ),
              Container(
                  child: Column(children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                      controller: bid,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 20.0),
                        hintText: "Bid Amount",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFECECEC),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      )),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: KButton(
                    onCall: () {
                      if (isNumber(bid.text)) {
                        addBid(bid.text);
                      } else {
                        _showDialog("Please enter the amount correctly");
                      }
                    },
                    text: "Add Bid",
                  ),
                )
              ])),
              Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            "Bid Winner ",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          //child: Text("Geeks",style: TextStyle(color:Colors.black,fontSize:25),),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(_bidWinner,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    backgroundColor: Colors.lightGreenAccent)),
                          ),

                          //child: Text("For",style: TextStyle(color:Colors.black,fontSize:25),),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ]),
              ),
              bidsList.length == 0
                  ? new Text("")
                  : new ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: bidsList.length,
                      itemBuilder: (_, index) {
                        if (bidsList[index].userId ==
                            FirebaseAuth.instance.currentUser.uid) {
                          flag = 1;
                        }

                        return PostUI(bidsList[index].auctionId,
                            bidsList[index].bid, bidsList[index].userName);
                      }),
            ])));
  }

  Widget PostUI(String auctionID, String user_name, String bid) {
    return new Container(
        child: Card(
      elevation: 10.0,
      margin: EdgeInsets.all(7.0),
      child: new Container(
        padding: new EdgeInsets.all(14.0),
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text(
                    user_name,
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                  new Text(
                    "${bid} Taka",
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ]),
      ),
    ));
  }
}

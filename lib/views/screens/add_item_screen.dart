import 'dart:math';
import 'package:biniyog/views/global_components/k_button.dart';
import 'package:biniyog/views/styles/k_colors.dart';
import 'package:biniyog/views/styles/k_text_style.dart';

import 'home_page.dart';
import 'user_items_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
class _AddItemScreenState extends State<AddItemScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  User user;
  final databaseRef = FirebaseDatabase.instance.reference().child("User");
  bool isLogged = false;
  bool isLoading = false;
  final name = TextEditingController();
  final description = TextEditingController();
  final minimumBidPrice = TextEditingController();
  final _date = TextEditingController();
  DateTime _selectedDate;
  final picker = ImagePicker();
  File sampleImage;

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      sampleImage = tempImage;
    });
  }

  checkAuthentication() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("start");
      }
    });
  }

  Future<void> addData(File sampleImage, String name, String des,
      String minBid, String date) async {
    String fileName = sampleImage.path;
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(sampleImage);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String url = await taskSnapshot.ref.getDownloadURL();
    print('URL Is $url');
    databaseRef.push().set({
      'Name': name,
      'Description': des,
      'Minimum_Bid_Price': minBid,
      'ImageURL': url,
      'End_Date': date,
      'UserID': user.uid,
      'AuctionID': randomID()
    });
    gotoHomePage();
  }

  String randomID() {
    var r = Random();
    return String.fromCharCodes(
        List.generate(7, (index) => r.nextInt(33) + 89));
  }

  void gotoHomePage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return new HomePage();
    }));
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
  }

  Widget enableUpload() {
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(sampleImage, height: 200.0, width: 300.0),
        ],
      ),
    );
  }

  _selectDate(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate != null ? _selectedDate : DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2040),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.deepPurple,
                onPrimary: Colors.white,
                surface: Colors.blueGrey,
                onSurface: Colors.black54,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child,
          );
        });

    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      _date
        ..text = DateFormat.yMMMd().format(_selectedDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _date.text.length, affinity: TextAffinity.upstream));
    }
  }

  @override
  Widget build(BuildContext context) {
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
            "Add Item",
            style: KTextStyle.headline2.copyWith(color: Colors.black),
          ),
        ),
        body: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                return Container(
                  child: !isLogged
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height / 1.3,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Form(
                    key: _formKey,
                        child: Column(
                            children: <Widget>[
                              SizedBox(height: 10.0),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(
                                          KColor.primary)),
                                  child: sampleImage == null
                                      ? Text('Upload an image')
                                      : enableUpload(),
                                  onPressed: getImage,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: TextField(
                                  controller: name,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 20.0),
                                    hintText: "Name",
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFFECECEC),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: TextField(
                                  controller: description,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 20.0),
                                    hintText: "description",
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFFECECEC),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: TextField(
                                  controller: minimumBidPrice,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 20.0),
                                    hintText: "Bid Price",
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFFECECEC),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: TextField(
                                  focusNode: AlwaysDisabledFocusNode(),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 20.0),
                                    hintText: "End Date of Auction",
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xFFECECEC),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  ),
                                  controller: _date,
                                  onTap: () {
                                    _selectDate(context);
                                  },
                                ),
                              ),
                              SizedBox(height: 20.0),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: KButton(
                                  text: "Save",
                                  onCall: () {
                                    addData(
                                        sampleImage,
                                        name.text,
                                        description.text,
                                        minimumBidPrice.text,
                                        _date.text);
                                    //CircularProgressIndicator();//call method flutter upload
                                  },
                                ),
                              ),
                            ],
                          ),
                      ),
                );
              }
            }));
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

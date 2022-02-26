import 'package:biniyog/services/navigation_service.dart';
import 'package:biniyog/views/global_components/k_button.dart';
import 'package:biniyog/views/screens/auth/login_screen.dart';
import 'package:biniyog/views/styles/k_colors.dart';
import 'package:biniyog/views/styles/k_text_style.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _name, _email, _password;

  checkAuthentication() async {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        Navigator.pushReplacementNamed(context, "/");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
  }

  signUp() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      try {
        UserCredential user = await _auth.createUserWithEmailAndPassword(
            email: _email, password: _password);
        if (user != null) {
          // UserUpdateInfo updateuser = UserUpdateInfo();
          // updateuser.displayName = _name;
          //  user.updateProfile(updateuser);
          await _auth.currentUser.updateProfile(displayName: _name);
          // await Navigator.pushReplacementNamed(context,"/") ;

        }
      } catch (e) {
        showError(e.message);
        print(e);
      }
    }
  }

  showError(String errormessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ERROR'),
            content: Text(errormessage),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: KColor.white,
          elevation: 0.0,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 24.0,top: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    FadeRoute(
                      page: LoginScreen(),
                    ),
                  );
                },
                child: Text("Log in",
                    style: KTextStyle.headline3.copyWith(fontSize: 15,color: Colors.black)),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 100,),
            Container(
              height: 100,
              child: Image(
                image: AssetImage("assets/images/b_logo.png"),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 50,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: TextFormField(
                          validator: (input) {
                            if (input.isEmpty) return 'Enter Name';
                          },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    contentPadding: EdgeInsets.only(left: 20.0),
                    hintText: "Enter name",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFECECEC),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                          onSaved: (input) => _name = input),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      child: TextFormField(
                          validator: (input) {
                            if (input.isEmpty) return 'Enter Email';
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.mail),
                            contentPadding: EdgeInsets.only(left: 20.0),
                            hintText: "Enter email",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFECECEC),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          onSaved: (input) => _email = input),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      child: TextFormField(
                          validator: (input) {
                            if (input.length < 6)
                              return 'Provide Minimum 6 Character';
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            contentPadding: EdgeInsets.only(left: 20.0),
                            hintText: "Enter password",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFECECEC),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          obscureText: true,
                          onSaved: (input) => _password = input),
                    ),
                    SizedBox(height: 20),
                KButton(
                  text: "SignUp",
                  onCall: (){
                    signUp();
                  },
                )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

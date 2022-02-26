import 'package:biniyog/services/navigation_service.dart';
import 'package:biniyog/views/global_components/k_button.dart';
import 'package:biniyog/views/screens/home_page.dart';
import 'package:biniyog/views/styles/k_colors.dart';
import 'package:biniyog/views/styles/k_text_style.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> googleSignIn() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken != null && googleAuth.accessToken != null) {
        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

        final UserCredential user =
            await _auth.signInWithCredential(credential);

        await Navigator.pushReplacementNamed(context, "/");

        return user;
      } else {
        throw StateError('Missing Google Auth Token');
      }
    } else
      throw StateError('Sign in Aborted');
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email, _password;

  checkAuthentication() async {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        print(user);

        Navigator.pushReplacement(context, FadeRoute(page: HomePage()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
  }

  login() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      try {
        await _auth.signInWithEmailAndPassword(
            email: _email, password: _password);
        ;
      } catch (e) {
        showError(e.message);
        print(e);
      }
    }
  }

  showError(String errorMessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ERROR'),
            content: Text(errorMessage),
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
                  Navigator.push(
                    context,
                    FadeRoute(
                      page: SignUpScreen(),
                    ),
                  );
                },
                child: Text("Create Account",
                    style: KTextStyle.headline3.copyWith(fontSize: 15,color: Colors.black)),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  height: 150,
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
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          child: TextFormField(
                              validator: (input) {
                                if (input.length < 6)
                                  return "Provide Minimum 6 Character";
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 20.0),
                                hintText: "Enter email",
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFFECECEC),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock),
                              ),
                              obscureText: true,
                              onSaved: (input) => _password = input),
                        ),
                        SizedBox(height: 20),
                        KButton(
                          onCall: () {
                            login();
                          },
                          text: "Log in",
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Or",
                  style: KTextStyle.headline3,
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: googleSignIn,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: KColor.grey, width: 1)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/google.png",
                          height: 40,
                          width: 40,
                        ),
                        Center(
                            child: Text(
                          "Signup with google",
                          style: KTextStyle.headline2,
                        ))
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

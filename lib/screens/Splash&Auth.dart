import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ourearth2020/screens/VisualPage.dart';
import 'package:ourearth2020/services/auth.dart';
String email,pass;
AuthService service = new AuthService();
final usernameController = TextEditingController();
final passController = TextEditingController();

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  void initState() {
    super.initState();
    Timer(Duration(seconds: 4), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => VisualPage()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(
              left: 80,
              right: 80
            ),
            child: LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow)  ,
            ),
          )
        ],
      ),

    );
  }
}

class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.yellow,
  borderRadius: BorderRadius.circular(15),
            ),
            child: MaterialButton(
              child: Text('Log In'),
              onPressed: (){
                print('HELLO');
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => LoginSignUp(signup:false,login:true)));              },

            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(15),
            ),
            child: MaterialButton(
              child: Text('Sign Up'),
              onPressed: (){
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => LoginSignUp(signup:true,login:false)));
              },

            ),
          )


        ],

      ),



    );
  }
}

class LoginSignUp extends StatefulWidget {
  bool login, signup;
  LoginSignUp({this.signup,this.login});
  @override
  _LoginSignUpState createState() => _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUp>  {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future firebaseAuth(email,pass) async{
    email.toString().trim;
    pass.toString().trim();
  if(widget.signup)
    {
        AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
        if(result==null)
        {
          print("RESULT IS NULL - CAN NOT CREATE USER ");
        }
        else {
          FirebaseUser user = result.user;
          print('USER UID:' + user.uid.toString());
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>VisualPage()));
        }
    }

  else{
    AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: pass);
    FirebaseUser user = result.user;
    print('USER UID:'+user.uid.toString());
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>VisualPage()));
  }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(child:Text(
              widget.signup ?'Sign Up':"Log In"
          )),
          TextField(
            controller: usernameController,
          decoration: InputDecoration(
            hintText: "Enter your username"
          ),

          ),
      TextField(
        controller: passController,
        decoration: InputDecoration(
            hintText: "Enter your password"
        ),

    ),
        Container(
          color: Colors.yellow,

          child: MaterialButton(
            child: Text('Submit'),
            onPressed: (){
              print('HELOOOOO');
              print(usernameController.text);
              print(passController.text);
              firebaseAuth(usernameController.text, passController.text);
              passController.clear();
              usernameController.clear();
            },
          ),
          ),
          Container(
            color: Colors.yellow,
            child: MaterialButton(
              child: Text(widget.signup?'Sign Up With Google':'Log In With Google'),
              onPressed: (){

              },
            ),
          )
        ],
      ),
      
    );
  }
}

 


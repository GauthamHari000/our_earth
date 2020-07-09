import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService{

final FirebaseAuth _auth = FirebaseAuth.instance;


Future signUpEmailPass(email,pass) async{
print('TEST');

}
Future logInEmailPass(email,pass) async{
  print('TEST');

}

}
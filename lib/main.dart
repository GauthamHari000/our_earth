import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ourearth2020/screens/VisualPage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/Splash&Auth.dart';
// Ensure that plugin services are initialized so that `availableCameras()`
// can be called before `runApp()`


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:VisualPage(),
    );
  }
}



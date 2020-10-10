import 'package:flutter/material.dart';

import 'dart:io';

import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';
import 'package:image_picker/image_picker.dart';

class ScreenVisualRecognition extends StatefulWidget {
  ScreenVisualRecognition({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _ScreenVisualRecognition createState() => _ScreenVisualRecognition();
}

class _ScreenVisualRecognition extends State<ScreenVisualRecognition> {
  IamOptions options;
  File _image;
  String _text = "Loading";
  String _text2 = "";
  String url;

  Future<Null> getOptions() async {
    this.options = await IamOptions(
        iamApiKey: "NRDjngCby2d-pSHOPyWQJxhuB6vOY2uOTCX6KV2BCfwB",
        url:
        "https://api.us-south.visual-recognition.watson.cloud.ibm.com/instances/ef286f4e-84c7-44e0-b63d-a6a49a142a30")
        .build();
    print(this.options.accessToken);
    print(this.options);
  }

  @override
  void initState() {
    // TODO: implement initState
    getOptions();
    super.initState();
  }

  void visualRecognitionUrl() async {
    //await getOptions();
    VisualRecognition visualRecognition =
    VisualRecognition(iamOptions: this.options, language: Language.ENGLISH);
    ClassifiedImages classifiedImages =
    await visualRecognition.classifyImageUrl(this.url);
    print(classifiedImages
        .getImages()[0]
        .getClassifiers()[0]
        .getClasses()[0]
        .className);
    setState(() {
      _text = classifiedImages.getImages()[0].getClassifiers()[0].toString();
      _text2 = classifiedImages
          .getImages()[0]
          .getClassifiers()[0]
          .getClasses()[0]
          .className;

    });
  }

  void visualRecognitionFile() async {
    //await getOptions();
    VisualRecognition visualRecognition =
    VisualRecognition(iamOptions: this.options, language: Language.ENGLISH);
    ClassifiedImages classifiedImages =
    await visualRecognition.classifyImageFile(_image.path);

    print("${_image.toString()}");
    print("${_image.path}");

    print(classifiedImages
        .getImages()[0]
        .getClassifiers()[0]
        .getClasses()[0]
        .className);
    print(classifiedImages
        .getImages()[0]
        .getClassifiers()[0].getClassifierName());
    ClassResult r =
    classifiedImages.getImages()[0].getClassifiers()[0].getClasses()[0];
    setState(() {
      _text = classifiedImages.getImages()[0].getClassifiers()[0].toString();
      _text2 = r.className + " " + r.score.toString();
      print(_text2);
    });
  }

  final picker = ImagePicker();

  Future getPhoto() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IBM Watson Visual Recognition"),
      ),
      body: SingleChildScrollView(
        child: Container(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _image == null
                  ? Text('Not image selected.')
                  : Image.file(
                _image,
                height: 300.0,
                width: 300.0,
              ),
              RaisedButton(
                child: const Text('Photo'),
                onPressed: getPhoto,
              ),
              Text("or"),
              Container(
                margin: const EdgeInsets.all(5.0),
                child: TextField(
                  decoration: InputDecoration(labelText: "Enter Url Image"),
                  onChanged: (String value) {
                    this.url = value;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(5.0),
                child: Text(_text2,
                    style:
                    TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
              ),
              Container(
                margin: const EdgeInsets.all(5.0),
                child: Text(_text),
              ),
              Container(
                margin: const EdgeInsets.all(10.0),
                child: RaisedButton(
                  child: const Text('Visual Recognition File'),
                  color: Theme.of(context).accentColor,
                  elevation: 4.0,
                  splashColor: Colors.blueGrey,
                  textColor: Colors.white,
                  onPressed: visualRecognitionFile,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10.0),
                child: RaisedButton(
                  child: const Text('Visual Recognition Url'),
                  color: Theme.of(context).accentColor,
                  elevation: 4.0,
                  splashColor: Colors.blueGrey,
                  textColor: Colors.white,
                  onPressed: visualRecognitionUrl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ScreenVisualRecognition(),
    );
  }
}
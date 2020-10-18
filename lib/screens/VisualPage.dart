import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ibm_watson/utils/IamOptions.dart';
import 'package:ibm_visual_recog_img_file/IBMVisualRecognition.dart';
import 'package:flutter_ibm_watson/utils/Language.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String classifier_id = "CompostxLandfillxRecycle_2056123069";
ClassifiedImages classifiedImage, classifiedHierarchy;
String className = "";
String hierarchy = "";
double score = 0.0;
int counter = 0;

class VisualPage extends StatefulWidget {
  List<String> scanMap;
  VisualPage({this.scanMap});
  @override
  _VisualPageState createState() => _VisualPageState();
}

class _VisualPageState extends State<VisualPage> {
  CameraController _controller;
  List cameras;
  int documentsLength;
  String path;
  List<String> drawerList;
  var galleryImage;
  var query;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  CameraDescription cameraDescription;

  Future initCamera() async {
    cameras = await availableCameras();
    var frontCamera = cameras.first;

    _controller = CameraController(frontCamera, ResolutionPreset.high);
    try {
      await _controller.initialize();
    } catch (e) {}
  }

  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      galleryImage = image;
    });
    return galleryImage;
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print('Running');
    updateDrawer();
    initCamera();
  }

  updateDrawer() async {
    await Firestore.instance
        .collection("ScanSaves")
        .getDocuments().then((val) {
      setState(() {
        query = val;
      });
    });

    print("HELlo"+query.documents.length.toString());
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
            child: ListView.builder(
                itemCount: query.documents.length,
                itemBuilder: (context, index) {
                  return new ListTile(
                    leading: Icon(Icons.favorite),
                    title: Text(query.documents[index].data["hierarchy"].toString().toUpperCase(),style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),),
                    subtitle: Text(query.documents[index].data["type"].toString()+" at \n "+query.documents[index].data["score"].toString()+" Confidence",style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),),
                  );
                })),
        backgroundColor: Colors.white,
        body: Stack(children: [
          FutureBuilder(
            future: initCamera(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return AspectRatio(
                  aspectRatio: MediaQuery.of(context).size.width /
                      MediaQuery.of(context).size.height,
                  child: CameraPreview(_controller),
                );
              } else {
                return Container(
                    child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                ));
              }
            },
          ),
          Positioned(
            top: MediaQuery.of(context).size.height - 110,
            left: 20,
            child: Container(
                decoration: BoxDecoration(
                  color: Colors.pink,
                  shape: BoxShape.circle,
                ),
                child: GestureDetector(
                  onTap: () async {
                    await getImageFromGallery();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DisplayPicture(image: galleryImage)));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                )),
          ),
          Container(
              decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )),
              padding: EdgeInsets.fromLTRB(0, 18, 0, 0),
              child: Text(
                "OurEarth Visual Recognition",
                style: TextStyle(fontSize: 25, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              width: double.infinity,
              height: 65),
          Positioned(
              top: MediaQuery.of(context).size.height - 120,
              left: 150,
              child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: () async {
                    final path = (await getTemporaryDirectory()).path +
                        '${DateTime.now()}.png';
                    try {
                      await _controller.takePicture(path);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  DisplayPicture(imagePath: path)));
                    } catch (e) {}
                  })),
          Positioned(
              top: MediaQuery.of(context).size.height - 110,
              right: 20,
              child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    width: 75,
                    height: 75,
                    child: Icon(
                      Icons.assessment,
                      size: 60,
                      color: Colors.white,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: () {
                    updateDrawer();
                    _scaffoldKey.currentState.openDrawer();
                  }))
        ]));
  }
}

class DisplayPicture extends StatefulWidget {
  String imagePath;
  File image;
  String _text;
  DisplayPicture({this.imagePath, this.image});
  @override
  _DisplayPictureState createState() => _DisplayPictureState();
}

class _DisplayPictureState extends State<DisplayPicture> {
  HashMap _map1 = new HashMap<int, String>();
  List<Widget> widgetList;
  List<String> prefsList;

  @override
  void initState() {
    super.initState();
    counter++;
  }

  Future<String> dataCollection() async {
    await visualImageClassifier(
            widget.image == null ? File(widget.imagePath) : widget.image)
        .then((value) => classifiedImage = value);
    await visualImageClassifierHierarchy(
            widget.image == null ? File(widget.imagePath) : widget.image)
        .then((hierarchy) => classifiedHierarchy = hierarchy);
    setState(() {
      className = classifiedImage
          .getImages()[0]
          .getClassifiers()[0]
          .getClasses()[0]
          .className;
      score = (classifiedImage
                  .getImages()[0]
                  .getClassifiers()[0]
                  .getClasses()[0]
                  .score *
              100)
          .roundToDouble();
      hierarchy = classifiedHierarchy
          .getImages()[0]
          .getClassifiers()[0]
          .getClasses()[0]
          .className;
    });
    _map1[0] = (className);
    _map1[1] = (score.toString() + "%");
    _map1[2] = (hierarchy);

    return _map1.toString();
  }

  Future<ClassifiedImages> visualImageClassifier(File image) async {
    IamOptions options = await IamOptions(
            iamApiKey: "NRDjngCby2d-pSHOPyWQJxhuB6vOY2uOTCX6KV2BCfwB",
            url: "https://gateway.watsonplatform.net/visual-recognition/api")
        .build();

    // setState(() {
    //   hierarchy=classifiedHierarchy.getImages()[0].getClassifiers()[0].getClasses()[0].className;
    // });

    IBMVisualRecognition visualRecognition = new IBMVisualRecognition(
        iamOptions: options, language: Language.ENGLISH);
    classifiedImage = await visualRecognition.MyClassifier_classifyImageFile(
        image.path, classifier_id);

    return classifiedImage;
    // print("Class name  " + classifiedImages.imagesProcessed.toString());
  }

  writeToFireBase() async {
    var _memoizer = AsyncMemoizer();
    await _memoizer.runOnce(() => Firestore.instance
        .collection("ScanSaves")
        .document(counter.toString())
        .setData({
          "type": _map1[0],
          "score": _map1[1],
          "hierarchy": _map1[2],
        })
        .then((value) => print("good"))
        .catchError((e) {
          print(e);
        }));
    return;
  }

  Future<ClassifiedImages> visualImageClassifierHierarchy(File image) async {
    IamOptions options = await IamOptions(
            iamApiKey: "NRDjngCby2d-pSHOPyWQJxhuB6vOY2uOTCX6KV2BCfwB",
            url: "https://gateway.watsonplatform.net/visual-recognition/api")
        .build();
    IBMVisualRecognition hierarchyVisualRecog = new IBMVisualRecognition(
        iamOptions: options, language: Language.ENGLISH);
    classifiedHierarchy =
        await hierarchyVisualRecog.classifyImageFile(image.path);

    return classifiedHierarchy;
    // print("Class name  " + classifiedImages.imagesProcessed.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
        ),
        body: Stack(children: [
          Center(
              child: widget.image == null
                  ? Image.file(File(widget.imagePath))
                  : Image.file(widget.image)),
          FutureBuilder(
              future: dataCollection(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //
                  writeToFireBase(); //   _memoizer.runOnce(() async => await ));
                  return Center(
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.pink),
                      child: Center(
                        child: Text(
                          _map1[0] + "\n" + _map1[1] + "\n" + _map1[2],
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                      ),
                    ),
                  );
                }
              }),
          Positioned(
              top: 50,
              left: 10,
              child: Container(
                  width: 75.0,
                  height: 75.0,
                  child: new FloatingActionButton(
                      shape: CircleBorder(),
                      elevation: 0.0,
                      child: Center(
                        child: Icon(
                          Icons.keyboard_arrow_left,
                          size: 35,
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      })))

          //     Center(
          //         child: widget.image == null
          //             ? Image.file(File(widget.imagePath))
          //             : Image.file(widget.image)),
          // Positioned(
          //     top: MediaQuery.of(context).size.height / 2,
          //     child: FloatingActionButton(
          //         child: Icon(Icons.arrow_right),
          //         onPressed: () async {
          //
          //           visualImageClassifier(widget.image == null
          //               ? File(widget.imagePath)
          //               : widget.image).then((value) =>
          //           classifiedImage=value
          //           );
          //           visualImageClassifierHierarchy(widget.image == null
          //               ? File(widget.imagePath)
          //               : widget.image).then((hierarchy) =>
          //           classifiedHierarchy=hierarchy
          //           );
          //
          //
          //
          //           // FutureBuilder(
          //           //     future: visualImageClassifier(widget.image == null
          //           //         ? File(widget.imagePath)
          //           //         : widget.image),
          //           //     builder: (context, snapshot) {
          //           //       if (snapshot.hasData) {
          //           //         print(snapshot.toString());
          //           //       } else
          //           //         print('NOD ATA');
          //           //     });
          //         })),
          //     Positioned(
          //         child:Text(className+"\n"+score.toString()+"%"+"\n"+hierarchy,style: TextStyle(
          //           color: Colors.deepPurple,
          //           fontSize: 40
          //         ),),
          //         top:150,
          //         right:140
          //
          //     ),
        ]));
  }
}

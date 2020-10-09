import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ibm_watson/utils/IamOptions.dart';
import 'package:ibm_visual_recog_img_file/IBMVisualRecognition.dart';
import 'package:flutter_ibm_watson/utils/Language.dart';
import 'package:ourearth2020/screens/Community.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path_provider/path_provider.dart';

String classifier_id = "CompostxLandfillxRecycle_2056123069";
ClassifiedImages classifiedImage,classifiedHierarchy;
String className="";
String hierarchy="";
double score =0.0;
class VisualPage extends StatefulWidget {
  @override
  _VisualPageState createState() => _VisualPageState();
}

class _VisualPageState extends State<VisualPage> {
  CameraController _controller;
  List cameras;
  String path;
  var galleryImage;

  CameraDescription cameraDescription;

  Future initCamera() async {
    cameras = await availableCameras();
    var frontCamera = cameras.first;

    _controller = CameraController(frontCamera, ResolutionPreset.high);
    try {
      await _controller.initialize();
    } catch (e) {}
    print('Controller Is Init:' + _controller.value.isInitialized.toString());
  }

  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      galleryImage = image;
    });
    print('GALLERY IMAGE' + galleryImage.toString());
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
    initCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: [
          FutureBuilder(
            future:initCamera(),
            builder: (context,snapshot){
              if (snapshot.connectionState==ConnectionState.done) {
                return AspectRatio(
                  aspectRatio: MediaQuery.of(context).size.width /
                      MediaQuery.of(context).size.height,
                  child: CameraPreview(_controller),
                );
              }
              else
                {
                  return Container(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                    )
                  );
                }

            },
          ),


          Positioned(
            top: MediaQuery.of(context).size.height - 120,
            child: GestureDetector(
                onTap: () async {
                  await getImageFromGallery();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DisplayPicture(image: galleryImage)));
                },
                child: Icon(
                  Icons.image,
                  color: Colors.white,
                  size: 60,
                )),
          ),
          Positioned(
              top: MediaQuery.of(context).size.height - 120,
              left: MediaQuery.of(context).size.width / 2.2,
              child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                      child: Icon(
                    Icons.camera,
                    color: Colors.white,
                    size: 60,
                  )),
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
                    } catch (e) {
                      print('EEEE' + e);
                    }
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




  Future<ClassifiedImages> visualImageClassifier(File image) async {
    IamOptions options = await IamOptions(
            iamApiKey: "NRDjngCby2d-pSHOPyWQJxhuB6vOY2uOTCX6KV2BCfwB",
            url: "https://gateway.watsonplatform.net/visual-recognition/api")
        .build();

    IBMVisualRecognition hierarchyVisualRecog = new IBMVisualRecognition(
        iamOptions: options, language: Language.ENGLISH);
    classifiedHierarchy =
    await hierarchyVisualRecog.classifyImageFile(image.path);
    // setState(() {
    //   hierarchy=classifiedHierarchy.getImages()[0].getClassifiers()[0].getClasses()[0].className;
    // });

    IBMVisualRecognition visualRecognition = new IBMVisualRecognition(
        iamOptions: options, language: Language.ENGLISH);
     classifiedImage =
        await visualRecognition.MyClassifier_classifyImageFile(
            image.path, classifier_id);


    return classifiedImage;
    // print("Class name  " + classifiedImages.imagesProcessed.toString());
  }
  Future<ClassifiedImages> visualImageClassifierHierarchy(File image) async {
    IamOptions options = await IamOptions(
        iamApiKey: "NRDjngCby2d-pSHOPyWQJxhuB6vOY2uOTCX6KV2BCfwB",
        url: "https://gateway.watsonplatform.net/visual-recognition/api")
        .build();
    IBMVisualRecognition visualRecognition = new IBMVisualRecognition(
        iamOptions: options, language: Language.ENGLISH);
     classifiedHierarchy =
    await visualRecognition.MyClassifier_classifyImageFile(
        image.path, classifier_id);

    return classifiedHierarchy;
    // print("Class name  " + classifiedImages.imagesProcessed.toString());
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [

          Center(
          child: widget.image == null
              ? Image.file(File(widget.imagePath))
              : Image.file(widget.image)),
      Positioned(
          top: MediaQuery.of(context).size.height / 2,
          child: FloatingActionButton(
              child: Icon(Icons.arrow_right),
              onPressed: () async {
                visualImageClassifier(widget.image == null
                    ? File(widget.imagePath)
                    : widget.image).then((value) =>
                classifiedImage=value
                );
                visualImageClassifierHierarchy(widget.image == null
                    ? File(widget.imagePath)
                    : widget.image).then((hierarchy) =>
                classifiedHierarchy=hierarchy
                );

                setState(() {
                  className = classifiedImage.getImages()[0].getClassifiers()[0].getClasses()[0].className;
                  score = classifiedImage.getImages()[0].getClassifiers()[0].getClasses()[0].score*100;
                  hierarchy=classifiedHierarchy.getImages()[0].getClassifiers()[0].getClasses()[0].className;
                  print("HIERARCHY"+hierarchy);
                });


                // FutureBuilder(
                //     future: visualImageClassifier(widget.image == null
                //         ? File(widget.imagePath)
                //         : widget.image),
                //     builder: (context, snapshot) {
                //       if (snapshot.hasData) {
                //         print(snapshot.toString());
                //       } else
                //         print('NOD ATA');
                //     });
              })),
          Positioned(
              child:Text(className+"\n"+score.toString()+"%"+"\n"+hierarchy,style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 40
              ),),
              top:150,
              right:140

          ),
    ]));
  }
}


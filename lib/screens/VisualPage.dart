import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ibm_watson/flutter_ibm_watson.dart';
import 'package:ibm_visual_recog_img_file/connection.dart';
import 'package:ourearth2020/screens/Community.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path_provider/path_provider.dart';

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
    displayPreview();
  }

  Future takePicture() {}

  bool displayPreview() {
    if (_controller == null || !_controller.value.isInitialized) {
      return false;
    } else {
      return true;
    }
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
          displayPreview()
              ? AspectRatio(
            aspectRatio: MediaQuery.of(context).size.width /
                MediaQuery.of(context).size.height,
            child: CameraPreview(_controller),
          )
              : Container(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height - 120,
            child: GestureDetector(
                onTap: () async {
                  await getImageFromGallery();
                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    DisplayPicture(image: galleryImage)
                  ));
                  print("RECEIVED");
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
                    print(
                        'ISINIT' + _controller.value.isInitialized.toString());
                    print(_controller.value.isTakingPicture);
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

class DisplayPicture extends StatelessWidget {
  String imagePath;
  File image;
  String _text;
  // File file = File(imagePath)
  DisplayPicture({this.imagePath, this.image});

   visualImageClassifier(File image) async{
      IamOptions options = await IamOptions(iamApiKey: "NRDjngCby2d-pSHOPyWQJxhuB6vOY2uOTCX6KV2BCfwB", url: "https://api.us-south.visual-recognition.watson.cloud.ibm.com/instances/ef286f4e-84c7-44e0-b63d-a6a49a142a30").build();
      VisualRecognition visualRecognition = new VisualRecognition(iamOptions: options, language: Language.ENGLISH); // Language.ENGLISH is language response
      ClassifiedImages classifiedImages = await visualRecognition.classifyImageFile(image.toString());
      print(classifiedImages.getImages()[0].getClassifiers()[0]);
    // StreamBuilder(
    //     stream: StreamMyClassifier(
    //         image,
    //         'NRDjngCby2d-pSHOPyWQJxhuB6vOY2uOTCX6KV2BCfwB', 'CompostxLandfillxRecycle_2056123069'),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData) {
    //         _text = snapshot.data;
    //         print(_text);
    //       }
    //       else {
    //  print('NO DATA AVAILABLE');
    //       }
    //
    //     }
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body:Stack(children:[Center(child:image==null?Image.file(File(imagePath)):Image.file(image)),Positioned(
      top: MediaQuery.of(context).size.height/2,
      child: FloatingActionButton(onPressed:() async{
        print('CLICKLED');
        await visualImageClassifier(image==null?File(imagePath):image);
      },
          child:Icon(Icons.arrow_right)),
    )]));

  }
}

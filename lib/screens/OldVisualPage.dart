
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
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
  var _image;
  String _text;
  Future getImageFromCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });

  }

  void visualImageClassifier()async{
    IamOptions options = await IamOptions(iamApiKey: "NRDjngCby2d-pSHOPyWQJxhuB6vOY2uOTCX6KV2BCfwB", url: "https://api.us-south.visual-recognition.watson.cloud.ibm.com/instances/ef286f4e-84c7-44e0-b63d-a6a49a142a30").build();
    VisualRecognition visualRecognition = new VisualRecognition(iamOptions: options, language: Language.ENGLISH); // Language.ENGLISH is language response
    ClassifiedImages classifiedImages = await visualRecognition.classifyImageUrl("https://starindojaya.com/images/products/PAPER_CUP_PAPERCUP_2_OZ.jpg");
    print(classifiedImages.getImages()[0].getClassifiers());
  }


  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: GestureDetector(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: _image == null
                        ? Text('NO IMAGE')
                        : new Image.file(_image)),
                Container(
                    child: StreamBuilder(
                        stream: StreamMyClassifier(
                            _image,
                            'NRDjngCby2d-pSHOPyWQJxhuB6vOY2uOTCX6KV2BCfwB', 'CompostxLandfillxRecycle_2056123069'),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            _text = snapshot.data;
                          return Center(
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height / 2),
                              child: Text(
                                _text,
                                style:
                                    TextStyle(color: Colors.white, fontSize: 33),
                              ),
                            ),
                          );
                        } else {
                          return Container(

                          child: RawMaterialButton(

                            onPressed: (){
                              visualImageClassifier();
                            },
                            fillColor: Colors.white,
                          child: Text('CHECK'),
                            ),
                            );
                        }
                      }),
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        closeManually: true,
        child: Icon(Icons.add_a_photo),
        children: [
          SpeedDialChild(
              child: Icon(Icons.camera),
              label: 'Camera',
              onTap: () {
                getImageFromCamera();
              }),
          SpeedDialChild(
              child: Icon(Icons.image),
              label: 'Gallery',
              onTap: () {
                getImageFromGallery();
              })
        ],
      ),
    );
  }
}
//


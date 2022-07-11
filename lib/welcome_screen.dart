

import 'dart:io';
import 'dart:math';
import 'package:tflite/tflite.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

import 'package:object_classification/video_page.dart';


const String yolo = "Tiny YOLOv2";



class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);
  static String id = 'welcome';

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  XFile? _image;
  late ImagePicker _imagePicker;
  bool isImage = false;
  String result = '';
  @override
  void initState(){
    super.initState();
    _imagePicker = ImagePicker();
    loadModelFiles();
  }
  void loadModelFiles()async{
    print('loading model');
    String? res = await Tflite.loadModel(
        model: "assets/model1.tflite",
        labels: "assets/read.txt",
        numThreads: 1, // defaults to 1
        isAsset: true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate: false // defaults to false, set to true to use GPU delegate
    );
  }
  Future predictFromModel()async{
    print('trying to predict');
    try{
      result = "";
      var recognitions = await Tflite.runModelOnImage(
          path: _image!.path,   // required
          imageMean: 0.0,   // defaults to 117.0
          imageStd: 255.0,  // defaults to 1.0
          numResults: 5,    // defaults to 5
          threshold: 0.005,   // defaults to 0.1
          asynch: true      // defaults to true
      );
      if(recognitions != null){
        // result = recognitions["detectedClass"];
        //todo for yolo
        // recognitions.map((re) {
        //   print('1');
        //   result = re["detectedClass"];
        // });
        //todo for simple object detector
        recognitions.forEach((element) {
          result += element['label'] + " " + (element['confidence'] as double).toStringAsFixed(2) + "\n ";
        });

      }
      print(result);
      setState(() {
        result;
      });
    }catch(e){
      print('error has occured: $e');
      //newely added
      // isImage = false;
    }
  }
  Future captureImageFromCamera()async{
    XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.camera);
    try {
      print('entering set state');
      print('pick image from galary');
      print('giving XFile _image ');

      setState(() {
        _image = pickedImage;
        //has been removed
        isImage = true;
        predictFromModel();
      });
    }catch(e){
      print(e);
    }
  }
  Future choseImageFromFolder()async{
    XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery);
    try {
      print('entering set state');
      print('pick image from galary');
      print('giving XFile _image ');

      setState(() {
        _image = pickedImage;
        isImage = true;
        predictFromModel();
      });
    }catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              if (isImage) Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(File(_image!.path),
                  width: 200,
                  height: 210,
                  fit: BoxFit.fill,
                ),
              ) else const Icon(Icons.image, size: 200,),
              Container(
                color: Colors.amberAccent,
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                margin: EdgeInsets.all(10.0),
                child: Text(result),
              ),
              TextButton(
                onPressed: (){
                  predictFromModel();
                },
                child: Container(
                color: Colors.amberAccent,
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                margin: EdgeInsets.all(10.0),
                child: Text('get prediction'),
              ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        choseImageFromFolder();
                      },
                      child: const Icon(Icons.folder, size: 80,),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        captureImageFromCamera();
                      },
                      child: const Icon(Icons.camera, size: 80,),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          Navigator.pushNamed(context, VideoFeedPage.id);
                        });
                      },
                      child: const Icon(Icons.video_call, size: 80,),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


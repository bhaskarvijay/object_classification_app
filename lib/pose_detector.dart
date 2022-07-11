
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

import 'package:object_classification/video_page.dart';

const String yolo = "Tiny YOLOv2";



class PoseDetector extends StatefulWidget {
  const PoseDetector({Key? key}) : super(key: key);
  static String id = 'welcome';

  @override
  _PoseDetectorState createState() => _PoseDetectorState();
}

class _PoseDetectorState extends State<PoseDetector> {
  XFile? _image;
  XFile? image1;
  late ImagePicker _imagePicker;
  bool isImage = false;
  String result = '';
  late double _imageHeight;
  late double _imageWidth;
  late List _recognitions;
  @override
  void initState(){
    super.initState();
    _imagePicker = ImagePicker();
    loadModelFiles();
  }
  void loadModelFiles()async{
    print('loading model');
    try{
      String? res = await Tflite.loadModel(
        model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
        // useGpuDelegate: true,
      );
    }on PlatformException {
      print('Failed to load model.');
    }
  }
  Future predictFromModel()async{
    if (_image == null) return;
      poseNet();

      _image!
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageHeight = info.image.height.toDouble();
        _imageWidth = info.image.width.toDouble();
      });
    }));
    setState(() {
      _image = image as XFile?;
    });
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
  Future poseNet() async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runPoseNetOnImage(
      path: _image!.path,
      numResults: 2,
    );

    print(recognitions);

    setState(() {
      _recognitions = recognitions!;
    });
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }
  List<Widget> renderKeypoints(Size screen) {
    if (_recognitions == null) return [];
    if (_imageHeight == null || _imageWidth == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageWidth * screen.width;

    var lists = <Widget>[];
    _recognitions.forEach((re) {
      var color = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
          .withOpacity(1.0);
      var list = re["keypoints"].values.map<Widget>((k) {
        return Positioned(
          left: k["x"] * factorX - 6,
          top: k["y"] * factorY - 6,
          width: 100,
          height: 12,
          child: Text(
            "● ${k["part"]}",
            style: TextStyle(
              color: color,
              fontSize: 12.0,
            ),
          ),
        );
      }).toList();

      lists..addAll(list);
    });

    return lists;
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


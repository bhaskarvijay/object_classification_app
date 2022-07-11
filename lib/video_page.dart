
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

List<CameraDescription>? cameras;
List<CameraDescription>? cameras1;

class VideoFeedPage extends StatefulWidget {
  const VideoFeedPage({Key? key}) : super(key: key);
  static String id = 'video feed';

  @override
  _VideoFeedPageState createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  late CameraImage _cameraImage;
  late CameraImage _cameraImage1;
  late CameraController controller;
  late CameraController controller1;
  XFile? _image;
  XFile? _image1;
  bool isVideo = true;
  bool isVideo1 = true;
  bool isPredicted = false;
  String result = '';
  @override
  void initState(){
    super.initState();
    loadModelFiles();
  }
  void cameraInit(){

  }
  void loadModelFiles()async{
    print('loading model');
    String? res = await Tflite.loadModel(
        model: "assets/mobilenet_v1_1.0_224.tflite",
        labels: "assets/mobilenet_v1_1.0_224.txt",
        numThreads: 1, // defaults to 1
        isAsset: true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate: false // defaults to false, set to true to use GPU delegate
    );
  }
  Future predictFromModel()async{
    print('trying to predict');
    try{

      var recognitions = await Tflite.runModelOnFrame(
          bytesList: _cameraImage.planes.map((plane) {return plane.bytes;}).toList(),// required
          imageHeight: _cameraImage.height,
          imageWidth: _cameraImage.width,
          imageMean: 127.5,   // defaults to 127.5
          imageStd: 127.5,    // defaults to 127.5
          rotation: 90,       // defaults to 90, Android only
          numResults: 5,      // defaults to 5
          threshold: 0.1,     // defaults to 0.1
          asynch: true        // defaults to true
      );
      if(recognitions != null){
        result = "";
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
    }
  }
  void videoPlayerMethod()async{
    try {
      print('checking available camers');
      cameras = await availableCameras();
      print('setting camera controller');
      controller = CameraController(cameras![0], ResolutionPreset.medium);
      print('camera initialize');
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          print('setState');
          controller.startImageStream((image) => {
            if(isVideo){
              isVideo = false,
              _cameraImage = image,
              predictFromModel(),
            }
            else{
              _cameraImage = image,
              predictFromModel(),
            }
          });
        });
      });
    }catch(e){
      print(e);
    }
  }
  void videoPlayerMethod1()async{
    try {
      // controller.stopVideoRecording();
      print('checking available camers');
      cameras1 = await availableCameras();
      print('setting camera controller');
      controller1 = CameraController(cameras1![2], ResolutionPreset.medium);
      print('camera initialize');
      controller1.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          print('setState');
          controller1.startImageStream((image1) => {
            if(isVideo1){
              isVideo1 = false,
              _cameraImage1 = image1,
            }
          });
        });
      });
    }catch(e){
      print(e);
    }
  }
  void dispose() {
    controller.dispose();
    controller1.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              isVideo ? const Icon(Icons.video_call, size: 100.0,) : Expanded(child: CameraPreview(controller)),
              isVideo1 ? const Icon(Icons.video_call, size: 100.0,) : Expanded(child: CameraPreview(controller1)),
              Container(
                color: Colors.amberAccent,
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                margin: EdgeInsets.all(10.0),
                child: Text(result),
              ),
              Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: (){
                          videoPlayerMethod();
                        },
                        child: const Icon(Icons.video_call, size: 80,),
                      ),
                      GestureDetector(
                        onTap: (){
                          videoPlayerMethod1();
                        },
                        child: const Icon(Icons.video_call, size: 80,),
                      )
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

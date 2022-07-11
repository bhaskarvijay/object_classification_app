import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';



class CameraManagerSystem extends StatefulWidget {
  const CameraManagerSystem({Key? key}) : super(key: key);

  @override
  _CameraManagerSystemState createState() => _CameraManagerSystemState();
}

class _CameraManagerSystemState extends State<CameraManagerSystem> {
  XFile? image;
  bool isImage = false;
  late ImagePicker _imagePicker;
  void initState(){
    super.initState();
    _imagePicker = ImagePicker();
  }
  Future choseImageFromFolder()async{
    XFile? pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery);
    try {
      setState(() {
        image = pickedImage;
        isImage = true;
      });
    }catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: isImage? Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.file(XFile(image!.path), width: 200, height: 210, fit: BoxFit.fill,),)
          : const Icon(Icons.image, size: 200,),
    );
  }
}

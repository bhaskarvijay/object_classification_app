import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:object_classification/video_page.dart';
import 'package:object_classification/welcome_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: Welcome.id,
      routes: {
        Welcome.id: (context) => const Welcome(),
        VideoFeedPage.id: (context) => const VideoFeedPage(),
      },
    );
  }
}


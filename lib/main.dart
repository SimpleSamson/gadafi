
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gadafi/aboutGadafi.dart';
import 'package:gadafi/webSpeaker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'pdfSpeaker.dart';
import 'workingprototype.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

enum TtsState { playing, stopped, paused, continued }

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: pdfSpeaker(),
        // Scaffold(
        // appBar: AppBar(
        //   title: Text('Gadafi'),
        // ),
        //home: webSpeaker(),
      routes:<String, WidgetBuilder>{
        '/pdfSpeaker' : (BuildContext context) => pdfSpeaker(),
        '/webSpeaker' : (BuildContext context) => webSpeaker(),
        '/settingsPage': (BuildContext context) => settingsPage(),
        '/aboutGadafi': (BuildContext context) => aboutGadafi(),
        }
    );
  }
}

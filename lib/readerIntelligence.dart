import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:beautiful_soup_dart/beautiful_soup.dart';

final userInputController = TextEditingController();
final userAddress = userInputController.text;
class sourceOfText extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => sourceOfTextState();
}
class sourceOfTextState extends State<sourceOfText>{

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[(
          TextFormField(controller: userInputController, decoration: const InputDecoration(label: Text('Address'), hintText: 'the location of the term sheet'),)),
        WebView(
          initialUrl: userAddress, //get from user
        ),
    ]
    );
  }
}
readingPrompts(String TextType)async{
  FlutterTts? ttsP;
  BeautifulSoup? bs;
  if(TextType == 'title'){
    //utter title
    ttsP?.setSilence(1500); //PAUSE//
    ttsP?.speak('title'); // = 'title' as SpeechSynthesisUtterance;
  }else if(TextType == 'subTitle') {
    ttsP?.setSilence(1500);
    ttsP?.speak('subtitle');
  }else if(TextType == 'image'){
    ttsP?.speak('Image detected, Pause the playback and view it or it will be skipped in 3 ${ttsP.setSilence(1500)} 2 ${ttsP.setSilence(1500)} 1 ${ttsP.setSilence(1500)}');
  }
}
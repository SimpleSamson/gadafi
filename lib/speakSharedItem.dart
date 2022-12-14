import 'lib/material.dart';
import 'pdfSpeaker.dart';
class speakSharedItem extends StatefulWidget{
  @override
  _speakSharedItemState createState() => _speakSharedItemState extends State<speakSharedItem>();
}

class _speakSharedItemState extends State<speakSharedItem> {
  static const platform = const MethodChannel("gadafiSpeakerChannel");

  @override
  void initState(){

    platform.setMethodCallHandler(nativeMethodCallHandler);
    super.initState();
  }
  Future<dynamic> nativeMethodCallHandler(MethodCall methodCall) async{
    print('Native Call Done HEre');
    switch(methodCall.method){
      // case "speakPdf":
      //   newText = pdfShared;
      //   return _speak();
      //   break;
      // default:
      //   newText = 'nothingShared';
      //   return _speak();
    }
  }
}
import 'lib/material.dart';
import 'pdfSpeaker.dart';
// class speakSharedItem extends StatefulWidget{
//   @override
//   _speakSharedItemState createState() => _speakSharedItemState extends State<speakSharedItem>();
// }
//
// class _speakSharedItemState extends State<speakSharedItem> {
//   static const platform = const MethodChannel("gadafiSpeakerChannel");
//
//   @override
//   void initState(){
//
//     platform.setMethodCallHandler(nativeMethodCallHandler);
//     super.initState();
//   }
//   Future<dynamic> nativeMethodCallHandler(MethodCall methodCall) async{
//     print('Native Call Done HEre');
//     switch(methodCall.method){
//       // case "speakPdf":
//       //   newText = pdfShared;
//       //   return _speak();
//       //   break;
//       // default:
//       //   newText = 'nothingShared';
//       //   return _speak();
//     }
//   }
// }
class speakSharedItem extends StatefulWidget{
  @override
  State<speakerSharedItem> createState() => _speakerSharedItemState();
}

class _speakerSharedItemState extends State<speakerSharedItem>{
  static const platform = MethodChannel('app.channel.shared.data');
  String? pdfSharedPath;// = 'no data yet';

  void initState(){
    super.initState();
    getSharedText();
    pdfSpeaker._pickPdfDocument2(pdfSharedPath);
  }
  Future<void> getSharedText() async{
    var pdfSharedPath = await platform.invokeMethod('getSharedText');
    if(sharedData != null){
      setState((){
        pdfSharedPath = sharedData;
      });
    }
  }
  // @override
  // Widget build(BuildContext context){
  //   return Scaffold(
  //   );
  // }
}
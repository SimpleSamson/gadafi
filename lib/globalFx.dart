import 'package:flutter/material.dart';
//import 'lib/material.dart';
import 'package:flutter_broadcasts/flutter_broadcasts.dart';
import 'pdfSpeaker.dart';
String? _textToBeRead = "Nothing Loaded";

class gadafiTitle extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _gadafiTitle();
}
class _gadafiTitle extends State<gadafiTitle> {
  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("Gadafi"),
          Center(child: IconButton(onPressed: () {
            Navigator.pushNamed(context, '/pdfSpeaker');
          }, icon: const Icon(Icons.picture_as_pdf_outlined))),
          Center(child: IconButton(onPressed: () {
            showDialog(context: context, builder: (BuildContext context){
              return AlertDialog(
                title: const Text('READ ONLINE PAGES'),
                content: const Text('UNDER CONSTRUCTION \nPlease Check Back Soon After Updating'),
                actions: <Widget>[
                  ElevatedButton(onPressed: (){ Navigator.of(context).pop();}, child: const Text('OK'))
                ],
              );
            });
//            Navigator.pushNamed(context, '/webSpeaker');
          }, icon: const Icon(Icons.http))),
          Center(child: IconButton(onPressed: (){Navigator.pushNamed(context, '/aboutGadafi');}, icon: Icon(Icons.question_mark_rounded)),)
        ]
    );
  }
}
//broadcasts
class handleSpeakerReceiver extends StatefulWidget{
  @override
  _handleSpeakerReceiverState createState() => _handleSpeakerReceiverState();
}
class _handleSpeakerReceiverState extends State<handleSpeakerReceiver>{
  BroadcastReceiver receiver = BroadcastReceiver(
  names: <String>["arg.airesol.gadafi.speakerReceiverHandling"]
  );

  void initState(){
    super.initState();
    receiver.start();
    receiver.messages.listen(print);
    }
  void dispose(){
    receiver.stop();
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
    return AlertDialog(
      title: Text("Gadafi"),
      content: pdfSpeaker(),
    );
}
}
/*
//by MarcosBoaventura stackoverflow
class ModalRoundedProgressBar extends StatefulWidget{
  ProgressBarHandler handler2;
  final double _opacity;
  final String _textMsg;
  final Function _handlerCallback;

  ModalRoundedProgressBar({
    @required Function this.handleCallback(ProgressBarHandler handler),//= _handlerCallback,// = Function() ,
    String message = "", //some text to show if needed
    double opacity = 0.7, //default value
  }) : _textMsg = message,
  _opacity = opacity,
  _handleCallback = handleCallback;

  @override
  State createState() => _ModalRoundedProgressBarState();
}
class _ModalRoundedProgressBarState extends State<ModalRoundedProgressBar> {
  bool _isShowing = false;

  @override
  void initState() {
    super.initState();
    ProgressBarHandler handler = ProgressBarHandler();

    handler.show = this.show; //show member holds a show method
    handler.dismiss = this.dismiss; //dismiss menber holds a dismiss method
    widget._handlerCallback(handler); //callback to send handler object
  }

  @override
  Widget build(BuildContext context) {
    //return a simple stack
    if (!isShowing) return Stack();

    //return an elegant display
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Opacity(opacity: widget._opacity,
            //make a modal effect
            child: ModalBarrier(
              dismissible: false,
              color: Colors.brown,
            ),
          ),
          Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text(widget._textMessage),
                ]
            ),
          ),
        ],
      ),
    );
  }
  // var progressBar = ModalRoundedProgressBar(
  //   handleCallback: (handler){
  //     _handler = handler;
  //   },
  // );
  //method to change state and show this bar
  void show() {
    setState(() => _isShowing = true);
  }

  //hide
  void dismiss() {
    setState(() => _isShowing = false);
  }

}
//handler class
class ProgressBarHandler
{
  Function show;
  Function dismiss;
}
//Center(child:CircularProgressIndicator(backgroundColor: Colors.brown, valueColor: AlwaysStoppedAnimation(Colors.greenAccent)));
*/
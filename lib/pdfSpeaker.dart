//import 'dart:html';
//import 'dart:html';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
//import 'lib/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
//import 'main.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:pdf_text/pdf_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_broadcasts/flutter_broadcasts.dart';
import 'controls.dart';
import 'globalFx.dart';
import 'settings.dart';
String _textToBeRead = "Nothing Loaded Yet";
bool _isLoading = false;

//ProgressBarHandler? _handler; //= ProgressBarHandler();
TextEditingController pageNumberController = TextEditingController();
class pdfSpeaker extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _pdfSpeakerState();
}

class _pdfSpeakerState extends State<pdfSpeaker> {
//  ProgressBarHandler _handler;
  PDFDoc? _pdfDoc;
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.7;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String? _newVoiceText;
  int? _inputLength;
  bool _awaitCompletion = false;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  bool get isWindows => !kIsWeb && Platform.isWindows;

  bool get isWeb => kIsWeb;

  @override
  initState() {
    super.initState();
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (isWeb || isIOS || isWindows) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() => flutterTts.getLanguages;

  Future<dynamic> _getEngines() => flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }
  Future _awaitSynthCompletion()async{
    if(_awaitCompletion == true){
      _loadingTextProgress;
    }
  }
  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _stop() async {
    _isLoading = false;
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(dynamic engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  void changedEnginesDropDownItem(String? selectedEngine) {
    flutterTts.setEngine(selectedEngine!);
    language = null;
    setState(() {
      engine = selectedEngine;
    });
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language!);
      if (isAndroid) {
        flutterTts
            .isLanguageInstalled(language!)
            .then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }

  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
      _awaitCompletion = true;
    });
  }

  // var progressBar = ModalRoundedProgressBar(
  //   handleCallback: (handler){
  //       _handler = handler;
  //     },
  // );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: gadafiTitle()),
      body: ListView(
        children: <Widget>[
          Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _pdfChoiceSection(),
                _btnSection(),
                _isLoading ? _loadingTextProgress() : Text('')

        ]
          ),
        ],
      ),
    );
  }

  _pdfChoiceSection() {
    //show choose pdf button that directs to selection dialog
    //on select show a pdf image of the title page and start playing
    //TODO: future releases give option of choosing page, continue reading, bookmark a location
    return Column(
        children: <Widget>[
          ListTile(
              iconColor: Colors.cyanAccent,
              minLeadingWidth: 35,
              title: Card(elevation: 7.0,
                  child: Column(children: [
                    Image.asset('images/7.png', width: 147, height: 147)
                  ])),
              onTap: ()=> _pickPdfDocument(),

                // showDialog(
                //   context:context,
                //   //barrierDismissable: false,
                //   builder: (BuildContext context){
                //     return Center(
                //       child: _pickPdfDocument(),
                //     );
                //   }
                //);
              //}
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(onPressed: (){
                  _pickPdfDocument;
                  //_isLoading ? _loadingTextProgress() : _showMouthing(); /* choose pdf*/
                  },
                    child: const Text('Choose')),
                //ElevatedButton(onPressed: (){ /* continue last reading */ }, child: const Text('continue')),
                IconButton(onPressed: () {
                  //_settingsDialog();
                  //_settingsPage();
                  Navigator.pushNamed(context, '/settingsPage');
//                  settingsPage();
                  //_enginesDropDownSection(engines)
                }, icon: Icon(Icons.build))
              ]
          ),
        ]
    );
  }

  Widget _engineSection() {
    if (isAndroid) {
      return FutureBuilder<dynamic>(
          future: _getEngines(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return _enginesDropDownSection(snapshot.data);
            } else if (snapshot.hasError) {
              return Text('Error loading engines...');
            } else
              return Text('Loading engines...');
          });
    } else
      return Container(width: 0, height: 0);
  }

  Widget _btnSection() {
    if (isAndroid) {
      return Container(
          padding: EdgeInsets.only(top: 50.0),
          child:
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildButtonColumn(Colors.green, Colors.greenAccent,
                Icons.play_arrow, 'PLAY', _speak),
            _buildButtonColumn(Colors.blue, Colors.blueAccent,
                Icons.pause, 'PAUSE', _pause),
            //TODO:
            _buildButtonColumn(
                Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop),
          ]));
    } else {
      return Container(
          padding: EdgeInsets.only(top: 50.0),
          child:
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildButtonColumn(Colors.green, Colors.greenAccent,
                Icons.play_arrow, 'PLAY', _speak),
            _buildButtonColumn(
                Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop),
            _buildButtonColumn(
                Colors.blue, Colors.blueAccent, Icons.pause, 'PAUSE', _pause),
          ]));
    }
  }

  Widget _enginesDropDownSection(dynamic engines) =>
      Container(
        padding: EdgeInsets.only(top: 50.0),
        child: DropdownButton(
          value: engine,
          items: getEnginesDropDownMenuItems(engines),
          onChanged: changedEnginesDropDownItem,
        ),
      );

  Widget _languageDropDownSection(dynamic languages) =>
      Container(
          padding: EdgeInsets.only(top: 10.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            DropdownButton(
              value: language,
              items: getLanguageDropDownMenuItems(languages),
              onChanged: changedLanguageDropDownItem,
            ),
            Visibility(
              visible: isAndroid,
              child: Text("Is installed: $isCurrentLanguageInstalled"),
            ),
          ]));

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(icon),
              color: color,
              splashColor: splashColor,
              onPressed: () => func()),
          Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: color)))
        ]);
  }

  ///use below method to divide the input from pdf or other text document since theres an error when text is too long
  // Future<int?> speechInputLengthDivider(String inputText) async {
  Future<String> speechInputDivided(String inputText) async {
    String y = 'Loading. Please wait';
    int? x = await flutterTts.getMaxSpeechInputLength;
    print(x.toString());
    if (inputText.length > x!) {
      //divide the input into parts and read them in sequence
      for (int i = 0; i < 10000000; i + x) {
        y = inputText.substring(0 + i, x + i);
      }
    }
    return y;
  }

  // Widget _getMaxSpeechInputLengthSection() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       ElevatedButton(
  //         child: Text('Get max speech input length'),
  //         onPressed: () async {
  //           _inputLength = await flutterTts.getMaxSpeechInputLength;
  //           setState(() {});
  //         },
  //       ),
  //       Text("$_inputLength characters"),
  //     ],
  //   );
  // }

  Widget _buildSliders() {
    return Column(
      children: [
        Text("volume"),
        _volume(),
        Text("pitch"),
        _pitch(),
        Text("rate"),
        _rate()
      ],
    );
  }

  Widget _volume() {
    return
      StatefulBuilder(
      builder:(context, state) =>
      Slider(
        value: volume,
        onChanged: (newVolume) {
          //setState(() => volume = newVolume);
          state(() => volume = newVolume);
        },
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: "Volume: $volume"
      )
    );
  }

  Widget _pitch() {
    return //StatefulBuilder(
        //builder:(context, state) =>
    Slider(
        value: pitch,
        onChanged: (newPitch) {
          setState(() => pitch = newPitch);
          //state(() => pitch = newPitch);
        },
        min: 0.5,
        max: 2.0,
        divisions: 15,
        label: "Pitch: $pitch",
        activeColor: Colors.red,
      //)
    );
  }

  Widget _rate() {
    return Slider(
      value: rate,
      onChanged: (newRate) {
        setState(() => rate = newRate);
        //state(() => rate = newRate);
      },
      min: 0.0,
      max: 1.0,
      divisions: 10,
      label: "Rate: $rate",
      activeColor: Colors.green,
    );
  }

  Future _pickPdfDocument() async {
    setState((){
      _isLoading = true;
      //   _loadingTextProgress();
    });
    var filePickerResult = await FilePicker.platform.pickFiles();
    if (filePickerResult != null) {
      _pdfDoc = await PDFDoc.fromPath(filePickerResult.files.single.path!);
      // Future x = await _awaitSynthCompletion().timeout(const Duration(seconds: 0), onTimeout:(){
      //   _loadingTextProgress();
      // });
      String docText = await _pdfDoc!.text;//.timeout(const Duration(seconds: 3), onTimeout: (){_loadingTextProgress(); return 'Loading. Please be patient as this may take a while.';});
      //_newVoiceText = await speechInputDivided(docText.toString()); //as String?;

      setState(() {
        //_handler.show();
        //_newVoiceText = await speechInputDivided(docText.toString());
        //isPlaying ? _loadingTextProgress(): _showMouthing();
        //this works (_speak() != true)? _showMouthing() : _loadingTextProgress();
        //_awaitSynthCompletion();
        //_awaitSynthCompletion() == null ? _loadingTextProgress(): _showMouthing();
//        while(TtsState.playing == true){
        _isLoading = false;
        _showMouthing(); //TODO: change or integrate       _awaitCompletion and _awaitSynthCompletion();
//        }
        _newVoiceText = docText.toString();
        // setState((){
        //       showProgress = !showProgress;
        //       if(showProgress){
        //         Future.delayed(const Duration(milliseconds: 1700),(){
        //           setState((){
        //             progress = 0.7;
        //           });
        //         });
        //         fab = Icon(Icons.stop);
        //       }else{
        //         fab = Icon(Icons.refresh);
        //       }
        //     }
        // );

       _speak();
        //_handler.dismiss();
      });
    }
  }
  Widget _loadingTextProgress() {
    // Icon fab = Icon(Icons.refresh);
    bool showProgress = false;
    // double progress = 0.2;
    void toggleSubmitState(){
      setState((){
        showProgress = !showProgress;
      });
    }
//    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>
        return AlertDialog(
          title: Text("Loading", textAlign: TextAlign.center,),
          content:
                  Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    Text('Loading. Please wait...', style: TextStyle(fontSize: 20),)
                  ]),
        );
//    )
  //  );
  }
  Widget _showMouthing() {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>
        AlertDialog(
            title: //Text("Reading"),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [CloseButton()],
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //TODO: page changes below
                Expanded(
                  child: Center(child: Image.asset('images/malemouth.gif')),
                ),
                _jumpToPage()
              ],
            ), contentPadding: EdgeInsets.all(17), actions: [_btnSection()]
        )));
    return Text('');
  }

  Future<String> getPdfText() async {
    String docText = await _pdfDoc!.text;
    //TODO choice of page
    setState(
            () {
          _textToBeRead = docText;
        }
    );
    return docText;
  }
  Widget _jumpToPage(){
    return Column(
      children: [
        TextFormField(
          keyboardType: TextInputType.number,
          controller: pageNumberController,
          decoration: const InputDecoration(
            hintText: 'Enter The Page Number To Go To',
            labelText: 'Page',
          ),
        ),
        ElevatedButton(onPressed: (){_readFromPage(int.parse(pageNumberController.text));}, child: const Text("GO TO PAGE"))
      ],
    );
  }
  Future<String> _readFromPage(int pageNo) async {
    String pageChoiceLoad = await _pdfDoc!.pageAt(pageNo).text;
//    String x = "Document not yet loaded";
    if (_pdfDoc == null) {
      pageChoiceLoad = "Please Choose A Document";
    }
    setState((){
      _textToBeRead = pageChoiceLoad;
    });
    setState((){
      pageChoiceLoad = pageChoiceLoad;
    });
    return pageChoiceLoad;
  }
//}
//class settingsPage extends StatefulWidget{
//  State<StatefulWidget> createState() => _settingsPageState();
//}
//class _settingsPageState extends State<pdfSpeaker>{
//  @override
  void _settingsPages(){//(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>
     AlertDialog(
            //mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.center,
       title:Text('settings'),
            content: //StatefulBuilder(
              //builder: (context, state) =>
                  Column(
              children: [
              _buildSliders(),
              _engineSection(),
              Text("Choose Engine"),
              ElevatedButton(onPressed: () {
                Navigator.pushNamed(context, '/pdfSpeaker');
              }, child: const Text("SAVE"))
                ]
              ),
            //)

    )
    ));
  }
  Widget _settingsDialog(){
    //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>
     return AlertDialog(
      title: Text('settings'),
      content: Column(
              children: [
              _buildSliders(),
              _engineSection(),
              Text("Choose Engine"),
              ElevatedButton(onPressed: () {
                Navigator.pushNamed(context, '/pdfSpeaker');
              }, child: const Text("SAVE"))
                ]
      )
    );//));
  }
}
class settingsPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _settingsPageState();
}
class _settingsPageState extends State<pdfSpeaker>{
  _pdfSpeakerState settingsWidgets = new _pdfSpeakerState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: gadafiTitle()),
      body: Column(
          children: [
            settingsWidgets._buildSliders(),
            //settingsWidgets._engineSection(),
            ElevatedButton(onPressed: () {
              Navigator.pushNamed(context, '/pdfSpeaker');
            }, child: const Text("SAVE"))
          ]
      ),
    );
  }

}
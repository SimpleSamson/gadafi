import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:gadafi/globalFx.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'controls.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

//String? _addressContent = 'No Content Yet';
var _addressContent;// = 'No Content Yet';
bool _isPaused = false;
bool _isStopped = false;
bool _isLoading = false;
bool _isPlaying = false;
class webSpeaker extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _webSpeakerState();
}

class _webSpeakerState extends State<webSpeaker> {
  ///////////////##############FROM HERE
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool _awaitCompletion = false;
  bool isCurrentLanguageInstalled = false;
  String? _newVoiceText;
  int? _inputLength;

  TtsState ttsState = TtsState.stopped;

  final addressForReadingCtr = TextEditingController();

  get isPlaying => ttsState == TtsState.playing;

  get isStopped => ttsState == TtsState.stopped;

  get isPaused => ttsState == TtsState.paused;

  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  bool get isWindows => !kIsWeb && Platform.isWindows;

  bool get isWeb => kIsWeb;

  final _addressFormKey = GlobalKey<FormState>();

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

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.speak(_newVoiceText!);
      }
    }
    _isPaused = false;
    _isPlaying = true;
    _isLoading = false;
    _isStopped = false;

  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _stop() async {
    _isStopped = true;
    _isPaused = false;
    _isPlaying = false;
    _isLoading = false;
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    _isStopped = false;
    _isPaused = true;
    _isPlaying = false;
    _isLoading = false;
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
    });
  }

/////////////////################## here
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(title: gadafiTitle(),),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 17.0),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _inputSection(),
                _btnSection(),
                Container(
                    child: _previewPageSection(),
                    width: size.width,
                    height: size.height * 0.49),
                _playerStatus()
              ],
            ),
          ],
        )
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

  Widget _futureBuilder() =>
      FutureBuilder<dynamic>(
          future: _getLanguages(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return _languageDropDownSection(snapshot.data);
            } else if (snapshot.hasError) {
              return Text('Error loading languages...');
            } else
              return Text('Loading Languages...');
          });

  Widget _inputSection() {
      return Column(
        children: [
          Form(
              key: _addressFormKey,
//      alignment: Alignment.topCenter,
              //    padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      maxLines: 11,
                      minLines: 1,
                      controller: addressForReadingCtr,
                      decoration: const InputDecoration(
                        label: const Text('address'),
                          hintText: 'www.website.com',
                      ),
                      validator: (value){
                        if(value==null||value.isEmpty){
                          return 'Please enter a web address';
                        }else if(value.contains('.') == false){ //since every webpage has a dot
                          return 'Please enter a valid address';
                        }
                        },
                    ),
                    Padding(padding: EdgeInsets.all(3.0)),
                    ElevatedButton.icon(
                      onPressed: () {
                        if(_addressFormKey.currentState!.validate()) {
                          readFromAddress(addressForReadingCtr.text);
                        }
                      },
                      label: const Text('load'),
                      icon: Icon(Icons.record_voice_over_outlined),
                    ),
                    // Container(
                    //child:
                  //  WebView(
                    //    initialUrl: addressForReadingCtr.text,
                   //     userAgent: 'gadafi'
                 //   ),
                    //), //TODO convert the body into readable text and load into below field
/*            TextFormField(
                  onChanged: (String $toBeRead) {
                    _onChange($toBeRead);
                  },
                ),
*/
                  ]
              )
          ),
        ],
      );
}
  Widget _btnSection() {
    if (isAndroid) {
      return Container(
          padding: EdgeInsets.only(top: 50.0),
          child:
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _buildButtonColumn(Colors.green, Colors.greenAccent,
                Icons.play_arrow, 'PLAY', _speak),
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

  Widget _previewPageSection(){
      return ListTile(
        minLeadingWidth: 35,
        title: Card(elevation: 7,
          child:
          //ListView(
          //  children: [
               WebView(
                initialUrl: addressForReadingCtr.text,
                 userAgent: 'gadafi'
               ),
         //   ],
         // ),
        //],
     ));
  }
  Widget _enginesDropDownSection(dynamic engines) => Container(
    padding: EdgeInsets.only(top: 50.0),
    child: DropdownButton(
      value: engine,
      items: getEnginesDropDownMenuItems(engines),
      onChanged: changedEnginesDropDownItem,
    ),
  );

  Widget _languageDropDownSection(dynamic languages) => Container(
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

  Widget _getMaxSpeechInputLengthSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          child: Text('Get max speech input length'),
          onPressed: () async {
            _inputLength = await flutterTts.getMaxSpeechInputLength;
            setState(() {});
          },
        ),
        Text("$_inputLength characters"),
      ],
    );
  }

  Widget _buildSliders() {
    return Column(
      children: [_volume(), _pitch(), _rate()],
    );
  }

  Widget _volume() {
    return Slider(
        value: volume,
        onChanged: (newVolume) {
          setState(() => volume = newVolume);
        },
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: "Volume: $volume");
  }

  Widget _pitch() {
    return Slider(
      value: pitch,
      onChanged: (newPitch) {
        setState(() => pitch = newPitch);
      },
      min: 0.5,
      max: 2.0,
      divisions: 15,
      label: "Pitch: $pitch",
      activeColor: Colors.red,
    );
  }

  Widget _rate() {
    return Slider(
      value: rate,
      onChanged: (newRate) {
        setState(() => rate = newRate);
      },
      min: 0.0,
      max: 1.0,
      divisions: 10,
      label: "Rate: $rate",
      activeColor: Colors.green,
    );
  }

  ///address is the address in form of airesol.org
  Future readFromAddress(String address) async {
      //get TextFromInternet
      //TODO script to return https if not available then http
      //TODO append www if absent
      var htmlTextRequest = Uri.tryParse('http://' + address.replaceAll(RegExp(r'https://'), '').replaceAll(RegExp(r'http://'), '')//.replaceAll(RegExp(r'www.'), ''),  //+ '192.168.43.198/index.html'
    );
//    var request = await http.Request('GET', htmlTextRequest as Uri);
    var request = await get(htmlTextRequest!);
   // var request = await http.read(htmlTextRequest);
    var response = request.body;
    BeautifulSoup htmlText = BeautifulSoup(response);
    // if(address.isEmpty){
    //   return AlertDialog(
    //     title: const Icon(Icons.warning_amber_rounded),
    //     content: const Text('Please Enter A Valid Address.'),
    //     actions: [ElevatedButton(
    //         onPressed: (){
    //           Navigator.of(context).pop();
    //         }, child: const Text('OK'))],
    //   );
    // }
    setState(() {
      _isLoading = true;
    });
    if(address.isNotEmpty){
      _addressContent = htmlText.body != null ? htmlText.body?.string : 'No Content Yet';

      print(response);
      print('content is ${htmlText}');
      setState(() {
        _isLoading = false;
        _isPlaying = true;
        print('address content is $_addressContent');
        _newVoiceText = _addressContent.toString();
        print('new voice is $_newVoiceText');
     //   _speak();
      //  _showMouthing(); //TODO: change or integrate       _awaitCompletion and _awaitSynthCompletion();
      });
    }
}
//remove title tags and add word Title to be read aloud then pause
  Widget _showMouthing() {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) =>
      AlertDialog(
        title: //Text("Reading"),
          Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [CloseButton()],
          ),
        content: Expanded(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //TODO: page changes below
            Expanded(
            child: Center(child: Image.asset('images/malemouth.gif')),
            ),
        //    _jumpToPage(),
            _playerStatus(),
          ],
        ),
        ),
        contentPadding: EdgeInsets.all(17),
        actions: [_btnSection()]
      )
    ));
    return Text('');
  }

  _playerStatus() {
    return Column(
      children: [
        _isLoading ? _loadingTextProgress() : Text(''),
        _isPlaying ? Text('Currently reading a web page...') : Text(''),
    //TODO: _isPaused ? Text('Playback Paused...') : Text(''),
    ],
    );
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
                  children: const [
                    CircularProgressIndicator(),
                    Text('Loading. Please wait...', style: TextStyle(fontSize: 20),)
                  ]),
        );
//    )
  //  );
  }
}

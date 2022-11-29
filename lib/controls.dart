import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'pdfSpeaker.dart';
//////////////////

late FlutterTts flutterTts;
String? language;
String? engine;
double volume = 0.5;
double pitch = 1.0;
double rate = 0.5;
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
}

Future _setAwaitOptions() async {
  await flutterTts.awaitSpeakCompletion(true);
}

List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(dynamic engines) {
  var items = <DropdownMenuItem<String>>[];
  for (dynamic type in engines) {
    items.add(DropdownMenuItem(
        value: type as String?, child: Text(type as String)));
  }
  return items;
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

/////////////////

enum TtsState { playing, stopped, paused, continued }

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






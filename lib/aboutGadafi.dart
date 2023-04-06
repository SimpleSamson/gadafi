import 'package:flutter/material.dart';

import 'globalFx.dart';

class aboutGadafi extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _aboutGadafiState();
}

class _aboutGadafiState extends State<aboutGadafi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: gadafiTitle(),),
      body: Text('Thank you for your interest in our app. Gadafi app is made to make the reading of digital books easier and faster. We enable you to listen to your favorite books, important documents and educative texts dictated while engaged in any other activity. Enjoy our app and update it regularly to get support for other text formats(we have started with PDF books) and new voices. \n Buy us coffee, thank us or even stop by and say hi or give feedback on our website.\n In case you would like to donate to educating the less priviledged in you community and developing nations attach a note to your donation to assist us with our records.'),
    );
  }
}
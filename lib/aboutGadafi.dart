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
      body: Padding(
        padding: const EdgeInsets.all(17.0),
        child: ListView(
              children: <Widget>[
                Image.asset('images/3.png', width: 167, height: 147,),
                Text('Thank you for your interest in our app. Gadafi app is made to make the reading of digital books easier and faster. We enable you to listen to your favorite books, important documents and educational texts dictated while you engage in other activities. Enjoy our app and update it regularly to get support for other text formats(we have started with PDF books) and new voices. \n', style: TextStyle(fontStyle: FontStyle.italic),),
                Text('\nFeeling generous or social?', style: TextStyle(fontStyle: FontStyle.italic),),
                Text('\nBuy us coffee, thank us or even stop by and say hi or give feedback on our website.\n '),
                Text('http://www.airesol.org/gadafi', textAlign: TextAlign.center, style: TextStyle(fontStyle: FontStyle.italic,)),
                Text('\nIn case you would like to donate to educating the less priviledged in your community and developing nations attach a note to your donation to assist us with our records and in developing the right areas and people that you like developed. And understand that in some areas a \$5 donation can feed a student for upto a week, buy books for note taking or even purchase a tiny solar panel for their phone to use this app especially those in rural areas or war torn regions that would like to educate themselves out of their conditions and circumstances.'),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class Result extends StatelessWidget {

  final int count;

  Result({Key key, this.count,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String msg = '';
    Widget img;
    if (0 <= count && count <= 400) {
      msg = 'need more alcohol';
      img = Image.asset('assets/images/1.png');
    } else if (400 <= count && count <= 800) {
      msg = 'i love everybody';
      img = Image.asset('assets/images/2.png');
    } else if (800 <= count && count <= 1500) {
      msg = 'time to call everybody';
      img = Image.asset('assets/images/3.png');
    } else if (1500 <= count && count <= 1900) {
      msg = 'Everyone is beautiful';
      img = Image.asset('assets/images/4.png');
    } else if (1900 <= count && count <= 2300) {
      msg = 'exotic dance';
      img = Image.asset('assets/images/5.png');
    } else if (2300 <= count && count <= 2800) {
      msg = 'let\'s f*ck anything';
      img = Image.asset('assets/images/6.png');
    } else if (2800 <= count) {
      msg = 'hospital';
      img = Image.asset('assets/images/6.png');
    }

    return Container(
      child: Column(
        children: <Widget>[
          Container(
            width: 120,
            height: 120,
            child: FittedBox(
              fit: BoxFit.contain,
              child: img,
            ),
          ),
          Container(
            child: Text(
              msg,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:music_project/3D_cards_home.dart';
import 'package:music_project/model/cards.dart';

class CardDetails extends StatelessWidget {
  const CardDetails({Key? key, required this.card}) : super(key: key);
  final Card3D card;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.black45,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: size.height * 0.1,
          ),
          Align(
            child: SizedBox(
                height: 150,
                child: Hero(
                    tag: Text(card.title), child: Card3DWidget(card: card))),
          ),
          SizedBox(
            height: 13,
          ),
          Text(
            card.title,
            style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            card.author,
            style: TextStyle(
                color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 17),
          ),
        ],
      ),
    );
  }
}

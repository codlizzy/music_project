import 'package:flutter/material.dart';

import '3D_cards_home.dart';

void main() {
  runApp(MyApp());
}
// cod.lizzy on instagram😍
//-----------------------
// codlizzy on Github🔥

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CardHome(),
    );
  }
}

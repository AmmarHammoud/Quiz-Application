import 'package:flutter/material.dart';
import 'package:flutter_app/main_screen.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'majalla',
          textTheme: TextTheme(
              bodyText1: TextStyle(fontSize: 26),
              bodyText2: TextStyle(fontSize: 24))),
      home: Scaffold(body: SafeArea(child: MyApp())),
    ),
  );
}

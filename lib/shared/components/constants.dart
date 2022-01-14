import 'package:flutter/material.dart';

Widget defaultAppBorderDecoration() => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        borderDecorationImage('assets/images/decoration/topLift.png'),
        Spacer(),
        borderDecorationImage('assets/images/decoration/topRight.png'),
      ],
    ),
    Spacer(),
    Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        borderDecorationImage(
            'assets/images/decoration/bottomLift.png'),
        Spacer(),
        borderDecorationImage('assets/images/decoration/bottomRight.png'),
      ],
    ),
  ],
);

Widget borderDecorationImage(String imageLocation) => Image.asset(
  imageLocation,
  width: 100,
  height: 100,
);
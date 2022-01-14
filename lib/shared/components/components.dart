import 'package:flutter/material.dart';

Text defaultText({@required context, @required String text}) => Text(
      text,
      style: Theme.of(context).textTheme.bodyText2,
      textAlign: TextAlign.center,
    );
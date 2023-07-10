import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PriorityLevel {
  static const String low = 'Low';
  static const String medium = 'Medium';
  static const String high = 'High';

  static Color getColor(String priority) {
    if (priority == 'Low') {
      return Colors.lightGreenAccent;
    } else if (priority == 'Medium') {
      return Colors.yellowAccent;
    } else {
      return Colors.redAccent;
    }
  }
}

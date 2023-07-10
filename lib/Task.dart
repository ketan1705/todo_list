import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Task {
  String name;
  bool isCompleted;
  String priority;

  Task({required this.name, this.isCompleted = false, required this.priority});

  Map<String, dynamic> toJson() {
    return {'name': name, 'isCompleted': isCompleted, 'priority': priority};
  }

  Task.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        isCompleted = json['isCompleted'],
        priority = json['priority'];
}

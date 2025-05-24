import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'TaskModel.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String sector;

  @HiveField(2)
  bool isDone;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String? description;

  @HiveField(5)
  TimeOfDay? scheduledTime;

  TaskModel({
    required this.name,
    required this.sector,
    required this.date,
    this.isDone = false,
    this.description,
    this.scheduledTime,
  });
}
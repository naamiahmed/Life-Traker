import 'package:hive/hive.dart';

part 'TaskModel.g.dart'; // Generated file

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String sector;

  @HiveField(2)
  bool isDone;

  TaskModel({required this.name, required this.sector, this.isDone = false});
}

import 'package:hive/hive.dart';

part 'SectorModel.g.dart';

@HiveType(typeId: 2)
class SectorModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String iconName;

  @HiveField(2)
  String colorName;

  SectorModel({
    required this.name,
    required this.iconName,
    required this.colorName,
  });
} 
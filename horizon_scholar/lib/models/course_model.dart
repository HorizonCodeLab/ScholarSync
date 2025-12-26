import 'package:hive/hive.dart';
part 'course_model.g.dart';

@HiveType(typeId: 2)
class CourseModel {
  @HiveField(0)
  String courseName;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  String certificationPath;

  @HiveField(3)
  String courseDescription;

  @HiveField(4)
  List<String> categories;

  CourseModel({
    required this.courseName,
    required this.isCompleted,
    required this.certificationPath,
    required this.courseDescription,
    List<String>? categories,
  }) : categories = categories ?? [];
}

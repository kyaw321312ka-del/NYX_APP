// lib/models/TrainingDetail.dart
class TrainingDetail {
  final int id;
  final String courseName;
  final List<Level> levels;
  final List<Schedule> schedules;

  TrainingDetail({
    required this.id,
    required this.courseName,
    required this.levels,
    required this.schedules,
  });

  factory TrainingDetail.fromJson(Map<String, dynamic> json) {
    return TrainingDetail(
      id: json['id'] as int? ?? 0,
      courseName: json['course_name']?.toString() ?? '',
      levels: (json['levels'] as List?)?.map((e) => Level.fromJson(e)).toList() ?? [],
      schedules: (json['schedules'] as List?)?.map((e) => Schedule.fromJson(e)).toList() ?? [],
    );
  }
}

class Level {
  final int id;
  final int price;
  final String? title;
  final String? details;
  final String? biography;
  final String? mainTitle;
  final String? aboutTitle;
  final String? description;
  final String titleLevel;
  final String? coachImageUrl;
  final String? instructorName;  // Fixed typo: was 'instsuctorName'
  final String? learningImageUrl;
  final String? learningDescription;
  final String? categoryCardImageUrl;

  Level({
    required this.id,
    required this.price,
    this.title,
    this.details,
    this.biography,
    this.mainTitle,
    this.aboutTitle,
    this.description,
    required this.titleLevel,
    this.coachImageUrl,
    this.instructorName,  // Fixed typo
    this.learningImageUrl,
    this.learningDescription,
    this.categoryCardImageUrl,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as int? ?? 0,
      price: json['price'] as int? ?? 0,
      title: json['title']?.toString(),
      details: json['details']?.toString(),
      biography: json['biography']?.toString(),
      mainTitle: json['main_title']?.toString(),
      aboutTitle: json['about_title']?.toString(),
      description: json['description']?.toString(),
      titleLevel: json['title_level']?.toString() ?? '',
      coachImageUrl: json['coach_image_url']?.toString(),
      instructorName: json['instructor_name']?.toString(),  // Fixed: 'instructor_name' not 'instsuctor_name'
      learningImageUrl: json['learning_image_url']?.toString(),
      learningDescription: json['learning_description']?.toString(),
      categoryCardImageUrl: json['category_card_image_url']?.toString(),
    );
  }
}

class Schedule {
  final String day;
  final int dayId;
  final int slotId;
  final String endTime;
  final String startTime;
  final int trainingLevelId;

  Schedule({
    required this.day,
    required this.dayId,
    required this.slotId,
    required this.endTime,
    required this.startTime,
    required this.trainingLevelId,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      day: json['day']?.toString() ?? '',
      dayId: json['day_id'] as int? ?? 0,
      slotId: json['slot_id'] as int? ?? 0,
      endTime: json['end_time']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      trainingLevelId: json['training_level_id'] as int? ?? 0,
    );
  }
}
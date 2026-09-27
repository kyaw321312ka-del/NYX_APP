class StudentEnrollment {
  final StudentInfo studentInfo;
  final List<ScheduleData> scheduleData;

  StudentEnrollment({
    required this.studentInfo,
    required this.scheduleData,
  });

  factory StudentEnrollment.fromJson(Map<String, dynamic> json) {
    return StudentEnrollment(
      studentInfo: StudentInfo.fromJson(json['studentInfo']),
      scheduleData: (json['scheduleData'] as List)
          .map((e) => ScheduleData.fromJson(e))
          .toList(),
    );
  }
}

class StudentInfo {
  final String date;
  final String time;
  final int id;
  final String name;
  final String gender;
  final int age;
  final String phone;
  final String email;
  final String paymentImageUrl;
  final String courseName;

  StudentInfo({
    required this.date,
    required this.time,
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.phone,
    required this.email,
    required this.paymentImageUrl,
    required this.courseName,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      date: json['Date']?.toString() ?? '',
      time: json['Time']?.toString() ?? '',
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      age: json['age'] as int,
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      paymentImageUrl: json['payment_image_url']?.toString() ?? '',
      courseName: json['course_name']?.toString() ?? '',
    );
  }
}

class ScheduleData {
  final int id;
  final String day;
  final String endTime;
  final String createAt;
  final String startTime;
  final String titleLevel;
  final int trainingLevelId;
  final int trainingProgramId;
  final int trainingScheduleDaysId;

  ScheduleData({
    required this.id,
    required this.day,
    required this.endTime,
    required this.createAt,
    required this.startTime,
    required this.titleLevel,
    required this.trainingLevelId,
    required this.trainingProgramId,
    required this.trainingScheduleDaysId,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) {
    return ScheduleData(
      id: json['id'] as int,
      day: json['day']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      createAt: json['create_at']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      titleLevel: json['title_level']?.toString() ?? '',
      trainingLevelId: json['training_level_id'] as int,
      trainingProgramId: json['training_program_id'] as int,
      trainingScheduleDaysId: json['training_schedule_days_id'] as int,
    );
  }
}
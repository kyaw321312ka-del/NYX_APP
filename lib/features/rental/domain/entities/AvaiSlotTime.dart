class AvailableSlot {
  final int id;
  final int courtId;
  final String startTime;
  final String endTime;
  final String createAt;

  AvailableSlot({
    required this.id,
    required this.courtId,
    required this.startTime,
    required this.endTime,
    required this.createAt,
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) {
    return AvailableSlot(
      id: json['id'] as int,
      courtId: json['court_id'] as int,
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      createAt: json['create_at']?.toString() ?? '',
    );
  }
}
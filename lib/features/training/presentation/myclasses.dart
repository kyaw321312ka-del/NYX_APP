import 'package:flutter/material.dart';
import 'package:nyxproject/features/training/domain/StudentEnrollment.dart';
import 'package:nyxproject/features/training/data/ClassApi/StudentEnrollmentApi.dart';
import 'package:nyxproject/core/storage/session_manager.dart';
import 'package:provider/provider.dart';

class Classes extends StatefulWidget {
  const Classes({super.key});

  @override
  State<Classes> createState() => _ClassesState();
}

class _ClassesState extends State<Classes> {
  List<StudentEnrollment> _enrollments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final sessionService = Provider.of<SessionService>(
        context,
        listen: false,
      );
      final token = sessionService.getToken();

      if (token == null) {
        setState(() {
          _error = 'Please login to view your classes';
          _isLoading = false;
        });
        return;
      }

      final result = await StudentEnrollmentApi.getStudentEnrollments(token: token);

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _enrollments = result['data'] ?? [];
          _isLoading = false;
        });
        print('✅ Loaded ${_enrollments.length} enrollments');
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load enrollments';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error loading enrollments: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "My Classes",
          style: TextStyle(
            fontFamily: "Custom",
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 13, 27, 42),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadEnrollments,
        color: Colors.red,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadEnrollments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_enrollments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                "No classes found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                "Your enrolled classes will appear here",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _enrollments.length,
      itemBuilder: (context, index) {
        final enrollment = _enrollments[index];
        return _enrollmentCard(enrollment);
      },
    );
  }

  Widget _enrollmentCard(StudentEnrollment enrollment) {
    final student = enrollment.studentInfo;
    final schedule = enrollment.scheduleData.isNotEmpty ? enrollment.scheduleData.first : null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 13, 27, 42),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  student.courseName,
                  style: const TextStyle(
                    fontFamily: "Custom",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Enrolled",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Name
                Row(
                  children: [
                    const Icon(Icons.person, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        student.name,
                        style: const TextStyle(
                          fontFamily: "Custom",
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Gender and Age
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      "${student.gender}, ${student.age} years old",
                      style: const TextStyle(
                        fontFamily: "Custom",
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Phone
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      student.phone,
                      style: const TextStyle(
                        fontFamily: "Custom",
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Email
                Row(
                  children: [
                    const Icon(Icons.email, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        student.email,
                        style: const TextStyle(
                          fontFamily: "Custom",
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                // Schedule
                if (schedule != null) ...[
                  const Text(
                    "Schedule",
                    style: TextStyle(
                      fontFamily: "Custom",
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        _getDayName(schedule.day),
                        style: const TextStyle(
                          fontFamily: "Custom",
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "${_formatTime(schedule.startTime)} - ${_formatTime(schedule.endTime)}",
                        style: const TextStyle(
                          fontFamily: "Custom",
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Level: ${_getLevelName(schedule.titleLevel)}",
                      style: TextStyle(
                        fontFamily: "Custom",
                        fontSize: 11,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Enrollment Date
                Row(
                  children: [
                    const Icon(Icons.event, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Enrolled on: ${student.date} at ${student.time}",
                        style: const TextStyle(
                          fontFamily: "Custom",
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? time) {
    if (time == null || time.isEmpty) return "";
    try {
      List<String> parts = time.split(':');
      int hour = int.parse(parts[0]);
      String minute = parts[1];
      String period = hour >= 12 ? "PM" : "AM";
      int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return "$displayHour:$minute $period";
    } catch (e) {
      return time;
    }
  }

  String _getDayName(String day) {
    switch (day.toLowerCase()) {
      case 'mon': return 'Monday';
      case 'tue': return 'Tuesday';
      case 'wed': return 'Wednesday';
      case 'thu': return 'Thursday';
      case 'fri': return 'Friday';
      case 'sat': return 'Saturday';
      case 'sun': return 'Sunday';
      default: return day;
    }
  }

  String _getLevelName(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return level;
    }
  }
}
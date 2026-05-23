class Lesson {
  const Lesson({
    required this.id,
    required this.discipline,
    required this.kindOfWork,
    required this.lecturer,
    required this.auditorium,
    required this.building,
    required this.group,
    required this.beginLesson,
    required this.endLesson,
    required this.date,
  });

  final int id;
  final String discipline;
  final String kindOfWork;
  final String lecturer;
  final String auditorium;
  final String building;
  final String group;
  final String beginLesson;
  final String endLesson;
  final String date;

  factory Lesson.fromJson(Map<String, dynamic> json, {required bool forPerson}) {
    final rawId = forPerson ? json['lecturerOid'] : json['lessonOid'];
    return Lesson(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      discipline: (json['discipline'] as String?) ?? '',
      kindOfWork: (json['kindOfWork'] as String?) ?? '',
      lecturer: (json['lecturer'] as String?) ?? '',
      auditorium: (json['auditorium'] as String?) ?? '',
      building: (json['building'] as String?) ?? '',
      group: (json['group'] as String?) ?? '',
      beginLesson: (json['beginLesson'] as String?) ?? '',
      endLesson: (json['endLesson'] as String?) ?? '',
      date: (json['date'] as String?) ?? '',
    );
  }
}

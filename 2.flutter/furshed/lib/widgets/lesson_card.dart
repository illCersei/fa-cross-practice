import 'package:flutter/material.dart';
import 'package:furshed/models/lesson.dart';

/// Карточка занятия (паттерн news_list).
class LessonCard extends StatelessWidget {
  const LessonCard({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.discipline,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 88,
                  child: Column(
                    children: [
                      Icon(Icons.school_outlined,
                          size: 40, color: Colors.green.shade700),
                      const SizedBox(height: 6),
                      Text(lesson.date, textAlign: TextAlign.center),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lesson.kindOfWork),
                      const SizedBox(height: 4),
                      Text('${lesson.auditorium} (${lesson.building})'),
                      const SizedBox(height: 4),
                      Text('${lesson.beginLesson} – ${lesson.endLesson}'),
                      if (lesson.group.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(lesson.group,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                      ],
                      if (lesson.lecturer.isNotEmpty)
                        Text(lesson.lecturer,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

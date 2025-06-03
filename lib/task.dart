import 'package:flutter/material.dart';

class Task {
  String id;
  String title;
  String description;
  bool isDone;
  DateTime? dueDate;
  int priority; // 0: Low, 1: Medium, 2: High

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isDone = false,
    this.dueDate,
    this.priority = 1,
  });

  factory Task.fromMap(Map<String, dynamic> data, String documentId) {
    return Task(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isDone: data['isDone'] ?? false,
      dueDate: data['dueDate']?.toDate(),
      priority: data['priority'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'dueDate': dueDate,
      'priority': priority,
    };
  }

  String get priorityText {
    switch (priority) {
      case 0:
        return 'Low';
      case 1:
        return 'Medium';
      case 2:
        return 'High';
      default:
        return 'Medium';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

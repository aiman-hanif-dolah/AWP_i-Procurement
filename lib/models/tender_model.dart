import 'package:cloud_firestore/cloud_firestore.dart';

class TenderModel {
  final String submissionId;
  final String title;
  final String description;
  final bool isOpen;
  final DateTime? startDate;
  final DateTime? endDate;

  TenderModel({
    required this.submissionId,
    required this.title,
    required this.description,
    required this.isOpen,
    this.startDate,
    this.endDate,
  });

  factory TenderModel.fromMap(Map<String, dynamic> map, String docId) {
    // Safely parse potential Timestamps or Strings for startDate/endDate
    DateTime? parsedStart;
    if (map['startDate'] is Timestamp) {
      parsedStart = (map['startDate'] as Timestamp).toDate();
    } else if (map['startDate'] is String) {
      try {
        parsedStart = DateTime.parse(map['startDate']);
      } catch (_) {}
    }

    DateTime? parsedEnd;
    if (map['endDate'] is Timestamp) {
      parsedEnd = (map['endDate'] as Timestamp).toDate();
    } else if (map['endDate'] is String) {
      try {
        parsedEnd = DateTime.parse(map['endDate']);
      } catch (_) {}
    }

    return TenderModel(
      submissionId: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isOpen: map['isOpen'] ?? false,
      startDate: parsedStart,
      endDate: parsedEnd,
    );
  }
}

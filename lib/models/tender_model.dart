import 'package:cloud_firestore/cloud_firestore.dart';

class TenderModel {
  final String id;
  final String title;
  final String description;
  final bool isOpen;
  final DateTime submissionDeadline;

  TenderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isOpen,
    required this.submissionDeadline,
  });

  factory TenderModel.fromMap(Map<String, dynamic> map, String id) {
    return TenderModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isOpen: map['isOpen'] ?? false,
      submissionDeadline: (map['submissionDeadline'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isOpen': isOpen,
      'submissionDeadline': submissionDeadline,
    };
  }
}

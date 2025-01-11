class SubmissionModel {
  final String id;
  final String vendorId;
  final String status;
  final String fileUrl;

  SubmissionModel({
    required this.id,
    required this.vendorId,
    required this.status,
    required this.fileUrl,
  });

  factory SubmissionModel.fromMap(Map<String, dynamic> data, String id) {
    return SubmissionModel(
      id: id,
      vendorId: data['vendorId'] ?? '',
      status: data['status'] ?? 'Pending',
      fileUrl: data['fileUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'status': status,
      'fileUrl': fileUrl,
    };
  }
}

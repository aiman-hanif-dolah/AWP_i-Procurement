class SubmissionModel {
  final String submissionId;
  final String vendorId;
  final String status;
  final String fileUrl;
  final String tenderId; // Added tenderId property

  SubmissionModel({
    required this.submissionId,
    required this.vendorId,
    required this.status,
    required this.fileUrl,
    required this.tenderId, // Added tenderId to constructor
  });

  factory SubmissionModel.fromMap(Map<String, dynamic> data, String submissionId) {
    // Validate submissionId
    if (submissionId.isEmpty) {
      throw ArgumentError('submissionId cannot be null or empty');
    }

    // Ensure all necessary values are present in the data map.
    if (data['vendorId'] == null) {
      throw ArgumentError('vendorId is required');
    }
    if (data['status'] == null) {
      throw ArgumentError('status is required');
    }
    if (data['fileUrl'] == null) {
      throw ArgumentError('fileUrl is required');
    }
    if (data['tenderId'] == null) {
      throw ArgumentError('tenderId is required');
    }

    return SubmissionModel(
      submissionId: submissionId,
      vendorId: data['vendorId'],
      status: data['status'],
      fileUrl: data['fileUrl'],
      tenderId: data['tenderId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'status': status,
      'fileUrl': fileUrl,
      'tenderId': tenderId, // Included tenderId in map
    };
  }
}

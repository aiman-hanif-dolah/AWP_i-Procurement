class VendorModel {
  final String id;
  final String name;
  final String companyName;
  final String email;
  final String phoneNumber;

  VendorModel({
    required this.id,
    required this.name,
    required this.companyName,
    required this.email,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'companyName': companyName,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  factory VendorModel.fromMap(Map<String, dynamic> map) {
    return VendorModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      companyName: map['companyName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}

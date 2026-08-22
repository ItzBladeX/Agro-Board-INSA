class UserModel {
  final int id;
  final String username;
  final String firstName;
  final String middleName;
  final String lastName;
  final String phoneNumber;
  final String? birthDate;
  final int? age;
  final String? gender;
  final double? landArea;
  final String role;
  final bool isActive;

  UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.phoneNumber,
    this.birthDate,
    this.age,
    this.gender,
    this.landArea,
    required this.role,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      middleName: json['middle_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      birthDate: json['birth_date'],
      age: json['age'],
      gender: json['gender'],
      landArea: json['land_area'] != null
          ? (json['land_area'] as num).toDouble()
          : null,
      role: json['role'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'birth_date': birthDate,
      'age': age,
      'gender': gender,
      'land_area': landArea,
      'role': role,
      'is_active': isActive,
    };
  }
}
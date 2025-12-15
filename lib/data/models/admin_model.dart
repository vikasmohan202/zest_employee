class LoginResponse {
  final String message;
  final Admin employee;
  final String accessToken;
  final String refreshToken;

  LoginResponse({
    required this.message,
    required this.employee,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      employee: Admin.fromJson(json['employee'] ?? {}),
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "employee": employee.toJson(),
      "accessToken": accessToken,
      "refreshToken": refreshToken,
    };
  }
}


class Admin {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? position;
  final String? profileImage;

  Admin({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.position,
    this.profileImage,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: (json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      position: json['position']?.toString(),
      profileImage: json['profileImage']?.toString(),
    );
  }
    Map<String, dynamic> toJson() {
    return {
      "id": id,
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      "position": position,
      "profileImage": profileImage,
    };
  }
}

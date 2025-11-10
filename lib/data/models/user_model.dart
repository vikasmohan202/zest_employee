class User {
  final String id;
  final String email;
  final String? name;

  User({required this.id, required this.email, this.name});

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: (json['_id'] ?? json['id'] ?? '').toString(),
        email: (json['email'] ?? '').toString(),
        name: json['name']?.toString(),
      );
}

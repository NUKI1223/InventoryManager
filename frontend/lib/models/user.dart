class User {
  final int id;
  final String username;
  final String? fullName;
  final String role;

  User({
    required this.id,
    required this.username,
    this.fullName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      fullName: json['fullName'],
      role: json['role'] ?? 'USER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'role': role,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? fullName,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
    );
  }
}

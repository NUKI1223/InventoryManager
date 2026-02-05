class PasswordResetRequest {
  final int id;
  final String username;
  final DateTime requestedAt;
  final String status;

  PasswordResetRequest({
    required this.id,
    required this.username,
    required this.requestedAt,
    required this.status,
  });

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) {
    return PasswordResetRequest(
      id: json['id'],
      username: json['username'],
      requestedAt: DateTime.parse(json['requestedAt']),
      status: json['status'],
    );
  }
}

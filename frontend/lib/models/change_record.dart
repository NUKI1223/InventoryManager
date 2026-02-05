class ChangeRecord {
  final int id;
  final int? productId;
  final String action;
  final int? performedBy;
  final String createdAt; // ISO string
  final String? details;

  ChangeRecord({
    required this.id,
    this.productId,
    required this.action,
    this.performedBy,
    required this.createdAt,
    this.details,
  });

  factory ChangeRecord.fromJson(Map<String, dynamic> json) {
    return ChangeRecord(
      id: (json['id'] as num).toInt(),
      productId: json['productId'] != null ? (json['productId'] as num).toInt() : null,
      action: json['action'] as String,
      performedBy: json['performedBy'] != null ? (json['performedBy'] as num).toInt() : null,
      createdAt: json['createdAt'] as String,
      details: json['details'] as String?,
    );
  }
}

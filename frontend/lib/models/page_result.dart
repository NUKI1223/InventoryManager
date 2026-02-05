class PageResult<T> {
  final List<T> content;
  final int number;
  final int size;
  final int totalPages;
  final int totalElements;

  PageResult({
    required this.content,
    required this.number,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  factory PageResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    final rawContent = json['content'] as List<dynamic>? ?? [];
    return PageResult(
      content: rawContent.map((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      number: json['number'] as int,
      size: json['size'] as int,
      totalPages: json['totalPages'] as int,
      totalElements: (json['totalElements'] as num).toInt(),
    );
  }
}

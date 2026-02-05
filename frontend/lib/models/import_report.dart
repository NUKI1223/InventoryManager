class RowError {
  final int row;
  final String message;
  RowError({required this.row, required this.message});
  factory RowError.fromJson(Map<String, dynamic> j) => RowError(
    row: j['row'] ?? 0,
    message: (j['message'] ?? '').toString(),
  );
}

class ImportReport {
  final int imported;
  final int updated;
  final List<RowError> errors;

  ImportReport({required this.imported, required this.updated, required this.errors});

  factory ImportReport.fromJson(Map<String, dynamic> j) {
    final errs = <RowError>[];
    if (j['errors'] is Iterable) {
      for (final e in (j['errors'] as Iterable)) {
        if (e is Map<String, dynamic>) errs.add(RowError.fromJson(e));
        else if (e is Map) errs.add(RowError.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return ImportReport(
      imported: (j['imported'] ?? 0) as int,
      updated: (j['updated'] ?? 0) as int,
      errors: errs,
    );
  }

  Map<String, dynamic> toJson() => {
    'imported': imported,
    'updated': updated,
    'errors': errors.map((e) => {'row': e.row, 'message': e.message}).toList(),
  };
}

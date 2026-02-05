class Stats {
  final int totalProducts;
  final int totalStock;
  final double totalInventoryValue;
  final int totalChanges;

  Stats({
    required this.totalProducts,
    required this.totalStock,
    required this.totalInventoryValue,
    required this.totalChanges,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalProducts: (json['totalProducts'] as num).toInt(),
      totalStock: (json['totalStock'] as num).toInt(),
      totalInventoryValue: (json['totalInventoryValue'] as num).toDouble(),
      totalChanges: (json['totalChanges'] as num).toInt(),
    );
  }
}

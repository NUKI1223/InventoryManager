import 'package:json_annotation/json_annotation.dart';

part 'stock_transaction.g.dart';

@JsonSerializable()
class StockTransaction {
  final int id;
  final int changeAmount;
  final String type;
  final String? reference;
  final String? note;
  final String createdAt;

  StockTransaction({
    required this.id,
    required this.changeAmount,
    required this.type,
    this.reference,
    this.note,
    required this.createdAt,
  });

  factory StockTransaction.fromJson(Map<String, dynamic> json) =>
      _$StockTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$StockTransactionToJson(this);
}

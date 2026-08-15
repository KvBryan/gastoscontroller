import 'dart:convert';

enum PaymentMethod {
  cash,
  card,
  transfer,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Efectivo';
      case PaymentMethod.card:
        return 'Tarjeta';
      case PaymentMethod.transfer:
        return 'Transferencia';
    }
  }

  String get key => name;

  static PaymentMethod fromKey(String key) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == key,
      orElse: () => PaymentMethod.cash,
    );
  }
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final PaymentMethod paymentMethod;
  final String notes;
  final bool isIncome;
  final String currency;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.paymentMethod,
    this.notes = '',
    required this.isIncome,
    required this.currency,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'categoryId': categoryId,
      'paymentMethod': paymentMethod.key,
      'notes': notes,
      'isIncome': isIncome,
      'currency': currency,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      categoryId: map['categoryId'] ?? 'other',
      paymentMethod: PaymentMethodExtension.fromKey(map['paymentMethod'] ?? 'cash'),
      notes: map['notes'] ?? '',
      isIncome: map['isIncome'] ?? false,
      currency: map['currency'] ?? '\$',
    );
  }

  String toJson() => json.encode(toMap());

  factory TransactionModel.fromJson(String source) => TransactionModel.fromMap(json.decode(source));
}

import 'dart:convert';

enum SubscriptionFrequency {
  daily,
  fortnightly, // quincenal
  monthly,
}

extension SubscriptionFrequencyExtension on SubscriptionFrequency {
  String get displayName {
    switch (this) {
      case SubscriptionFrequency.daily:
        return 'Diario';
      case SubscriptionFrequency.fortnightly:
        return 'Quincenal';
      case SubscriptionFrequency.monthly:
        return 'Mensual';
    }
  }

  String get key => name;

  static SubscriptionFrequency fromKey(String key) {
    return SubscriptionFrequency.values.firstWhere(
      (e) => e.name == key,
      orElse: () => SubscriptionFrequency.monthly,
    );
  }
}

class SubscriptionModel {
  final String id;
  final String title;
  final double amount;
  final String categoryId;
  final int dueDate; // Day of the month or frequency parameter (e.g. day of quincena 1-15)
  final String notes;
  final bool isActive;
  final String currency;
  final SubscriptionFrequency frequency;

  SubscriptionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.dueDate,
    this.notes = '',
    this.isActive = true,
    required this.currency,
    this.frequency = SubscriptionFrequency.monthly,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'categoryId': categoryId,
      'dueDate': dueDate,
      'notes': notes,
      'isActive': isActive,
      'currency': currency,
      'frequency': frequency.key,
    };
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      categoryId: map['categoryId'] ?? 'other',
      dueDate: map['dueDate'] ?? 1,
      notes: map['notes'] ?? '',
      isActive: map['isActive'] ?? true,
      currency: map['currency'] ?? '\$',
      frequency: SubscriptionFrequencyExtension.fromKey(map['frequency'] ?? 'monthly'),
    );
  }

  String toJson() => json.encode(toMap());

  factory SubscriptionModel.fromJson(String source) => SubscriptionModel.fromMap(json.decode(source));
}

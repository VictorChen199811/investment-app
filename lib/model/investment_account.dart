


class InvestmentAccount {
  final int id;
  final String name; // 帳戶名稱（例如：台幣證券帳戶）
  final String currency; // 幣別（例如：TWD, USD, JPY）
  final String category; // 帳戶類別（美股、台股、other）
  final String? note; // 備註

  InvestmentAccount({
    required this.id,
    required this.name,
    required this.currency,
    required this.category,
    this.note,
  });

  InvestmentAccount copyWith({
    int? id,
    String? name,
    String? currency,
    String? category,
    String? note,
  }) {
    return InvestmentAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'currency': currency,
      'category': category,
      'note': note,
    };
  }

  factory InvestmentAccount.fromMap(Map<String, dynamic> map) {
    return InvestmentAccount(
      id: map['id'] as int,
      name: map['name'] as String,
      currency: map['currency'] as String,
      category: map['category'] as String,
      note: map['note'] as String?,
    );
  }
}

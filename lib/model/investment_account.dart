


class InvestmentAccount {
  final int id;
  final String name;       // 帳戶名稱（例如：台幣證券帳戶）
  final String currency;   // 幣別（例如：TWD, USD, JPY）
  final String? note;      // 備註

  InvestmentAccount({
    required this.id,
    required this.name,
    required this.currency,
    this.note,
  });

  InvestmentAccount copyWith({
    int? id,
    String? name,
    String? currency,
    String? note,
  }) {
    return InvestmentAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      note: note ?? this.note,
    );
  }
}
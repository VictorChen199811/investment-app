


class FundingRecord {
  final int id;
  final int accountId;         // 所屬帳戶 ID
  final DateTime transferDate; // 匯款日期
  final double sourceAmount;   // 原始匯出金額（如台幣）
  final double exchangeRate;   // 當時匯率（如 TWD→USD 匯率）
  final double targetAmount;   // 匯入帳戶實得金額（外幣）
  final double wireFee;        // 電匯手續費（以匯出幣別計價）
  final String? note;          // 備註

  FundingRecord({
    required this.id,
    required this.accountId,
    required this.transferDate,
    required this.sourceAmount,
    required this.exchangeRate,
    required this.targetAmount,
    required this.wireFee,
    this.note,
  });

  FundingRecord copyWith({
    int? id,
    int? accountId,
    DateTime? transferDate,
    double? sourceAmount,
    double? exchangeRate,
    double? targetAmount,
    double? wireFee,
    String? note,
  }) {
    return FundingRecord(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      transferDate: transferDate ?? this.transferDate,
      sourceAmount: sourceAmount ?? this.sourceAmount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      targetAmount: targetAmount ?? this.targetAmount,
      wireFee: wireFee ?? this.wireFee,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'transferDate': transferDate.millisecondsSinceEpoch,
      'sourceAmount': sourceAmount,
      'exchangeRate': exchangeRate,
      'targetAmount': targetAmount,
      'wireFee': wireFee,
      'note': note,
    };
  }

  factory FundingRecord.fromMap(Map<String, dynamic> map) {
    return FundingRecord(
      id: map['id'] as int,
      accountId: map['accountId'] as int,
      transferDate:
          DateTime.fromMillisecondsSinceEpoch(map['transferDate'] as int),
      sourceAmount: (map['sourceAmount'] as num).toDouble(),
      exchangeRate: (map['exchangeRate'] as num).toDouble(),
      targetAmount: (map['targetAmount'] as num).toDouble(),
      wireFee: (map['wireFee'] as num).toDouble(),
      note: map['note'] as String?,
    );
  }
}

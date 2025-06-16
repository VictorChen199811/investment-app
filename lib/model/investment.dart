class Investment {
  final int id;
  final int accountId; // 關聯帳戶 ID
  final String symbol; // 股票或標的代碼
  final double buyPrice; // 買入單價
  final int quantity; // 買入數量
  final double fee; // 手續費
  final double? tax; // 稅費（可選）
  final double? otherCost; // 其他成本（可選）
  final double currentPrice; // 當前市價
  final DateTime buyDate; // 買入日期
  final String? note; // 備註

  Investment({
    required this.id,
    required this.accountId,
    required this.symbol,
    required this.buyPrice,
    required this.quantity,
    required this.fee,
    this.tax,
    this.otherCost,
    required this.currentPrice,
    required this.buyDate,
    this.note,
  });

  double get totalCost {
    // 買入單價 * 買入數量 + 手續費 + 稅費 + 其他成本
    return buyPrice * quantity + fee + (tax ?? 0) + (otherCost ?? 0);
  }

  Investment.newInvestment({
    required this.accountId,
    required this.symbol,
    required this.buyPrice,
    required this.quantity,
    required this.fee,
    this.tax,
    this.otherCost,
    required this.currentPrice,
    required this.buyDate,
    this.note,
  }) : id = -1;

  Investment copyWith({
    int? id,
    int? accountId,
    String? symbol,
    double? buyPrice,
    int? quantity,
    double? fee,
    double? tax,
    double? otherCost,
    double? currentPrice,
    DateTime? buyDate,
    String? note,
  }) {
    return Investment(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      symbol: symbol ?? this.symbol,
      buyPrice: buyPrice ?? this.buyPrice,
      quantity: quantity ?? this.quantity,
      fee: fee ?? this.fee,
      tax: tax ?? this.tax,
      otherCost: otherCost ?? this.otherCost,
      currentPrice: currentPrice ?? this.currentPrice,
      buyDate: buyDate ?? this.buyDate,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'accountId': accountId,
      'symbol': symbol,
      'buyPrice': buyPrice,
      'quantity': quantity,
      'fee': fee,
      'tax': tax,
      'otherCost': otherCost,
      'currentPrice': currentPrice,
      'buyDate': buyDate.millisecondsSinceEpoch,
      'note': note,
    };
    return map;
  }

  factory Investment.fromMap(Map<String, dynamic> map) {
    return Investment(
      id: map['id'] as int,
      accountId: map['accountId'] as int,
      symbol: map['symbol'] as String,
      buyPrice: (map['buyPrice'] as num).toDouble(),
      quantity: map['quantity'] as int,
      fee: (map['fee'] as num).toDouble(),
      tax: (map['tax'] as num?)?.toDouble(),
      otherCost: (map['otherCost'] as num?)?.toDouble(),
      currentPrice: (map['currentPrice'] as num).toDouble(),
      buyDate: DateTime.fromMillisecondsSinceEpoch(map['buyDate'] as int),
      note: map['note'] as String?,
    );
  }
}

class Transaction
{
  bool transactionType;
  double amount;
  DateTime dateTime;
  String description;
  String paymentMethod;

  Transaction({
    required this.transactionType,
    required this.amount,
    required this.dateTime,
    required this.description,
    required this.paymentMethod,
  });

  factory Transaction.fromJson(Map<String, dynamic> json)
  {
    return Transaction(
      transactionType: json['transactionType'],
      amount: (json['amount'] as num).toDouble(),
      dateTime: DateTime.parse(json['dateTime']),
      description: json['description'],
      paymentMethod: json['paymentMethod'],
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'transactionType': transactionType,
      'amount': amount,
      'dateTime': dateTime.toIso8601String(),
      'description': description,
      'paymentMethod': paymentMethod,
    };
  }

  void addTransaction() {}

  void updateTransaction({double? newAmount, String? newDesc})
  {
    if (newAmount != null) amount = newAmount;
    if (newDesc != null) description = newDesc;
  }

  void deleteTransaction() {}

  bool validate()
  {
    return amount > 0 && description.isNotEmpty;
  }
}

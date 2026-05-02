class Transaction {
  int id;
  int userId;
  bool transactionType; 
  double amount;
  DateTime dateTime;
  String description;
  String paymentMethod;
  int categoryId;

  Transaction({
    required this.id,
    required this.userId,
    required this.transactionType,
    required this.amount,
    required this.dateTime,
    required this.description,
    required this.paymentMethod,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'transactionType': transactionType ? 1 : 0,
        'amount': amount,
        'dateTime': dateTime.toIso8601String(),
        'description': description,
        'paymentMethod': paymentMethod,
        'categoryId': categoryId,
      };

  factory Transaction.fromMap(Map<String, dynamic> map) => Transaction(
        id: map['id'],
        userId: map['userId'],
        transactionType: map['transactionType'] == 1,
        amount: (map['amount'] as num).toDouble(),
        dateTime: DateTime.parse(map['dateTime']),
        description: map['description'],
        paymentMethod: map['paymentMethod'],
        categoryId: map['categoryId'],
      );

  bool validate() => amount > 0 && description.isNotEmpty;
}

class Account {
  int? accountId;
  int userId;
  double balance;
  String currency;

  Account({
    this.accountId,
    required this.userId,
    required this.balance,
    required this.currency,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'userId': userId,
      'balance': balance,
      'currency': currency,
    };
    if (accountId != null && accountId != 0) {
      map['accountId'] = accountId;
    }
    return map;
  }

  factory Account.fromMap(Map<String, dynamic> map) => Account(
        accountId: map['accountId'],
        userId: map['userId'],
        balance: (map['balance'] as num).toDouble(),
        currency: map['currency'],
      );

  void deposit(double amount) {
    if (amount > 0) balance += amount;
  }

  bool withdraw(double amount) {
    if (amount > 0 && balance >= amount) {
      balance -= amount;
      return true;
    }
    return false;
  }
}
class Account
{
  int accountId;
  double balance;
  String currency;

  Account({
    required this.accountId,
    required this.balance,
    required this.currency,
  });

  factory Account.fromJson(Map<String, dynamic> json)
  {
    return Account(
      accountId: json['accountId'],
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'accountId': accountId,
      'balance': balance,
      'currency': currency,
    };
  }

  void deposit(double amount)
  {
    if (amount > 0) balance += amount;
  }

  bool withdraw(double amount)
  {
    if (amount > 0 && balance >= amount)
    {
      balance -= amount;
      return true;
    }
    return false;
  }

  double getBalance()
  {
    return balance;
  }
}

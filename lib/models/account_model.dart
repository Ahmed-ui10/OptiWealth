/// Represents a user's financial account and manages its balance.
///
/// This class encapsulates the business logic for modifying funds, 
/// ensuring that balances cannot be altered improperly from outside the class.
class Account {
  /// The unique identifier for the account (can be null before database insertion).
  int? accountId;
  
  /// The ID of the user who owns this account.
  int userId;
  
  /// The current available funds in the account.
  double balance;
  
  /// The currency abbreviation used for this account (e.g., 'EGP', 'USD').
  String currency;

  /// Creates a new [Account] instance.
  Account({
    this.accountId,
    required this.userId,
    required this.balance,
    required this.currency,
  });

  /// Converts the [Account] instance into a Map for database storage.
  ///
  /// The [accountId] is omitted if it is null or zero to allow the 
  /// database to auto-increment the ID upon insertion.
  Map<String, dynamic> toMap()
  {
    final map = <String, dynamic>{
      'userId': userId,
      'balance': balance,
      'currency': currency,
    };
    if (accountId != null && accountId != 0)
    {
      map['accountId'] = accountId;
    }
    return map;
  }

  /// Reconstructs an [Account] instance from a database [map].
  factory Account.fromMap(Map<String, dynamic> map) => Account(
        accountId: map['accountId'],
        userId: map['userId'],
        balance: (map['balance'] as num).toDouble(),
        currency: map['currency'],
      );

  /// Adds a specified [amount] to the account's [balance].
  ///
  /// The operation is only performed if the [amount] is strictly positive.
  void deposit(double amount)
  {
    if (amount > 0) balance += amount;
  }

  /// Deducts a specified [amount] from the account's [balance].
  ///
  /// Returns `true` if the withdrawal was successful.
  /// Returns `false` if the [amount] is invalid or if there are 
  /// insufficient funds (amount exceeds current [balance]).
  bool withdraw(double amount)
  {
    if (amount > 0 && balance >= amount)
    {
      balance -= amount;
      return true;
    }
    return false;
  }
}

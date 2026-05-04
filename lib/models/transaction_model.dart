/// Represents a single financial record, which can be either an income or an expense.
///
/// This class encapsulates the details of a transaction and provides internal 
/// validation to ensure data integrity before interacting with the database.
class Transaction {
  /// The unique identifier for the transaction (can be null before database insertion).
  int? id;
  
  /// The ID of the user who owns this transaction.
  int userId;
  
  /// Indicates the financial direction: `true` represents Income, `false` represents Expense.
  bool transactionType;
  
  /// The monetary value of the transaction.
  double amount;
  
  /// The exact date and time the transaction took place.
  DateTime dateTime;
  
  /// A brief, user-provided explanation or note about the transaction.
  String description;
  
  /// The medium used for the transaction (e.g., 'Cash', 'Credit Card', 'Bank Transfer').
  String paymentMethod;
  
  /// The ID of the category this transaction falls under.
  int categoryId;

  /// Creates a new [Transaction] instance.
  Transaction({
    this.id,
    required this.userId,
    required this.transactionType,
    required this.amount,
    required this.dateTime,
    required this.description,
    required this.paymentMethod,
    required this.categoryId,
  });

  /// Converts the [Transaction] instance into a Map for database storage.
  ///
  /// Since SQLite does not have a native boolean type, the [transactionType] 
  /// is explicitly converted to an integer (`1` for true, `0` for false).
  /// The [id] is omitted if it is null or zero to allow auto-incrementation.
  Map<String, dynamic> toMap()
  {
    final map = <String, dynamic>{
      'userId': userId,
      'transactionType': transactionType ? 1 : 0,
      'amount': amount,
      'dateTime': dateTime.toIso8601String().split('.')[0],
      'description': description,
      'paymentMethod': paymentMethod,
      'categoryId': categoryId,
    };
    if (id != null && id != 0)
    {
      map['id'] = id;
    }
    return map;
  }

  /// Reconstructs a [Transaction] instance from a local SQLite database [map].
  ///
  /// Parses the integer representation of [transactionType] back into a boolean.
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

  /// Validates the core data of the transaction.
  ///
  /// Returns `true` only if the monetary [amount] is strictly positive 
  /// and a valid [description] has been provided.
  bool validate() => amount > 0 && description.isNotEmpty;
}

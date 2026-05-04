/// Represents a classification for a financial transaction or budget.
///
/// Categories help organize cash flow, allowing the system to track
/// where money is coming from (income) and where it is going (expense).
class Category {
  /// The unique identifier for the category.
  int categoryId;
  
  /// The display name of the category (e.g., 'Groceries', 'Salary', 'Rent').
  String name;
  
  /// Indicates the financial direction of the category.
  /// 
  /// Expected values are typically strictly 'income' or 'expense'.
  String type;

  /// Creates a new [Category] instance.
  Category({
    required this.categoryId,
    required this.name,
    required this.type,
  });

  /// Converts the [Category] instance into a Map for database storage.
  Map<String, dynamic> toMap() => {
        'categoryId': categoryId,
        'name': name,
        'type': type,
      };

  /// Reconstructs a [Category] instance from a local SQLite database [map].
  factory Category.fromMap(Map<String, dynamic> map) => Category(
        categoryId: map['categoryId'],
        name: map['name'],
        type: map['type'],
      );
}

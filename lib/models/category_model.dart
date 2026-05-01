class Category {
  int categoryId;
  String name;
  String type; // 'income' or 'expense'

  Category({
    required this.categoryId,
    required this.name,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
        'categoryId': categoryId,
        'name': name,
        'type': type,
      };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        categoryId: map['categoryId'],
        name: map['name'],
        type: map['type'],
      );
}
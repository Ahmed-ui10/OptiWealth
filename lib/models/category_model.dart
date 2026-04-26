class Category
{
  int categoryId;
  String name;
  String type;

  Category({
    required this.categoryId,
    required this.name,
    required this.type,
  });

  factory Category.fromJson(Map<String, dynamic> json)
  {
    return Category(
      categoryId: json['categoryId'],
      name: json['name'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'categoryId': categoryId,
      'name': name,
      'type': type,
    };
  }

  void createCategory() {}

  void updateCategory(String newName)
  {
    name = newName;
  }
}

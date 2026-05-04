class User {
  int? id;
  String fullName;
  String email;
  String passwordHash;
  String currency;
  String language;
  bool notificationsEnabled;

  User({
    this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    required this.currency,
    required this.language,
    this.notificationsEnabled = true,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'passwordHash': passwordHash,
      'currency': currency,
      'language': language,
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
    };
    if (id != null && id != 0) {
      map['id'] = id;
    }
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'],
    fullName: map['fullName'],
    email: map['email'],
    passwordHash: map['passwordHash'],
    currency: map['currency'],
    language: map['language'],
    notificationsEnabled: map['notificationsEnabled'] == 1,
  );
}

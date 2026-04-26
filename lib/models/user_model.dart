class User
{
  String fullName;
  String email;
  String passwordHash;
  String currency;
  String language;
  bool notificationsEnabled;

  User({
    required this.fullName,
    required this.email,
    required this.passwordHash,
    required this.currency,
    required this.language,
    this.notificationsEnabled = true,
  });

  factory User.fromJson(Map<String, dynamic> json)
  {
    return User(
      fullName: json['fullName'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      currency: json['currency'],
      language: json['language'],
      notificationsEnabled: json['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'fullName': fullName,
      'email': email,
      'passwordHash': passwordHash,
      'currency': currency,
      'language': language,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  void register() {}

  bool login(String inputEmail, String inputPasswordHash)
  {
    return email == inputEmail && passwordHash == inputPasswordHash;
  }

  void updateProfile({String? newName, String? newLanguage, String? newCurrency})
  {
    if (newName != null) fullName = newName;
    if (newLanguage != null) language = newLanguage;
    if (newCurrency != null) currency = newCurrency;
  }
}

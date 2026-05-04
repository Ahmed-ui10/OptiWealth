/// Represents a registered user within the system.
///
/// This class holds the user's personal information, authentication details, 
/// and application preferences (such as language and default currency).
class User {
  /// The unique identifier for the user (can be null before database insertion).
  int? id;  
  
  /// The user's complete legal or display name.
  String fullName;
  
  /// The user's email address, typically used as a login credential.
  String email;
  
  /// The hashed version of the user's password to ensure security.
  String passwordHash;
  
  /// The user's preferred currency for all financial displays (e.g., 'EGP', 'USD').
  String currency;
  
  /// The user's preferred application language code (e.g., 'ar', 'en').
  String language;
  
  /// Indicates whether the user has opted in to receive system alerts and warnings.
  bool notificationsEnabled;

  /// Creates a new [User] profile instance.
  ///
  /// By default, [notificationsEnabled] is set to `true` unless specified otherwise.
  User({
    this.id,  
    required this.fullName,
    required this.email,
    required this.passwordHash,
    required this.currency,
    required this.language,
    this.notificationsEnabled = true,
  });

  /// Converts the [User] instance into a Map for database storage.
  ///
  /// Since SQLite lacks a native boolean type, [notificationsEnabled] is 
  /// explicitly converted to an integer (`1` for true, `0` for false).
  /// The [id] is omitted if it is null or zero so the database can auto-increment it.
  Map<String, dynamic> toMap()
  {
    final map = <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'passwordHash': passwordHash,
      'currency': currency,
      'language': language,
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
    };
    if (id != null && id != 0)
    {
      map['id'] = id;
    }
    return map;
  }

  /// Reconstructs a [User] profile from a local SQLite database [map].
  ///
  /// Reverts the integer representation of [notificationsEnabled] back to a boolean.
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

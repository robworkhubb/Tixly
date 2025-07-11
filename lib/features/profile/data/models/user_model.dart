class User {
  final String uid;
  final String? email;
  final String displayName;
  final String? profileImageUrl;
  final bool darkMode;

  User({
    required this.uid,
    this.email,
    required this.displayName,
    this.profileImageUrl,
    this.darkMode = false,
  });

  factory User.fromMap(Map<String, dynamic> data, String docId) {
    return User(
      uid: docId,
      email: data['email'] as String?,
      // se displayName è null -> stringa vuota
      displayName: (data['displayName'] as String?)?.trim() ?? '',
      // profileImageUrl può essere null
      profileImageUrl: data['profileImageUrl'] as String?,
      // se darkMode è null -> false
      darkMode: (data['darkMode'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'displayName': displayName,
    'profileImageUrl': profileImageUrl,
    'darkMode': darkMode,
  };

  User copyWith({
    String? displayName,
    String? profileImageUrl,
    bool? darkMode,
  }) {
    return User(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}
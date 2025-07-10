class User {
  final String uid;
  String? email;
  String displayName;
  String? profileImageUrl;
  final bool darkMode;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    this.darkMode = false,
  });

  factory User.fromMap(Map<String, dynamic> data, String docId) {
    return User(
      uid: data['uid'],
      email: data['email'],
      displayName: data['displayName'],
      profileImageUrl: data['profileImageUrl'],
      darkMode: data['darkMode'] as bool ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'darkMode': darkMode,
  };

  User copyWith({String? displayName, String? profileImageUrl, bool? darkMode}) {
    return User(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}

class User {
  final String uid;
  final String? email;
  final String displayName;
  final String? profileImageUrl;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
  });

  factory User.fromMap(Map<String, dynamic> data, String docId) {
    return User(
      uid: data['uid'],
      email: data['email'],
      displayName: data['displayName'],
      profileImageUrl: data['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
    };
  }

  User copyWith({String? displayName, String? profileImageUrl}) {
    return User(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

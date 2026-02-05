class User {
  final String id;
  final String username;
  final String email;
  final bool isAdmin;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.isAdmin,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

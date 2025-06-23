class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final DateTime createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  // Convert User to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create User from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Create a copy of User with updated fields
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, createdAt: $createdAt}';
  }
}

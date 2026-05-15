class AppUser {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) {
    return AppUser(
      id:        j['_id'] as String,
      name:      j['name'] as String,
      email:     j['email'] as String,
      createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id':       id,
    'name':      name,
    'email':     email,
    'createdAt': createdAt.toIso8601String(),
  };
}
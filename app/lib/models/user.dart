class User {
  final String id;
  final String name;
  final String email;
  final String role; // "pencari" atau "pemilik"

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'pencari',
  });

  /// Pemilik kos boleh menambah iklan dan mengelola iklan miliknya.
  bool get isPemilik => role == 'pemilik';

  String get roleLabel => isPemilik ? 'Pemilik kos' : 'Pencari kos';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] ?? '-',
      email: json['email'] ?? '-',
      role: json['role'] ?? 'pencari',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
  };
}

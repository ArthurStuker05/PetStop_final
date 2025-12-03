class Pet {
  final String id;
  final String userId;
  final String name;
  final String breed;
  final int age;
  final double weight;
  final List<String> vaccines;
  final List<String> allergies;
  final String medicalNotes;
  final DateTime createdAt;

  Pet({
    required this.id,
    required this.userId,
    required this.name,
    required this.breed,
    required this.age,
    required this.weight,
    this.vaccines = const [],
    this.allergies = const [],
    this.medicalNotes = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'breed': breed,
      'age': age,
      'weight': weight,
      'vaccines': vaccines,
      'allergies': allergies,
      'medicalNotes': medicalNotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      age: map['age'] ?? 0,
      weight: (map['weight'] ?? 0.0).toDouble(),
      vaccines: List<String>.from(map['vaccines'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
      medicalNotes: map['medicalNotes'] ?? '',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}


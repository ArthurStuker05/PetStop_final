enum ServiceType {
  bath,
  grooming,
  veterinary,
}

class Service {
  final String id;
  final ServiceType type;
  final String name;
  final String description;
  final double price;

  Service({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'name': name,
      'description': description,
      'price': price,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] ?? '',
      type: ServiceType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ServiceType.bath,
      ),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }
}


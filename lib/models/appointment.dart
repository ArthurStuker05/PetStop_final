enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

class Appointment {
  final String id;
  final String userId;
  final String petId;
  final String serviceId;
  final DateTime date;
  final String time;
  final AppointmentStatus status;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.petId,
    required this.serviceId,
    required this.date,
    required this.time,
    this.status = AppointmentStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'petId': petId,
      'serviceId': serviceId,
      'date': date.toIso8601String(),
      'time': time,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      petId: map['petId'] ?? '',
      serviceId: map['serviceId'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      time: map['time'] ?? '',
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}


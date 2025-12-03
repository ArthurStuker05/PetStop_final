import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';
import '../models/service.dart';

class AppointmentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'appointments';

  // --- Proteção Contra Duplicidade (Versão Firebase) ---
  Future<bool> hasDuplicateAppointment(String petId, DateTime date, String time) async {
    try {
      // Busca agendamentos desse Pet
      final snapshot = await _firestore
          .collection(_collection)
          .where('petId', isEqualTo: petId)
          .get();

      // Verifica se algum bate com o horário que queremos marcar
      return snapshot.docs.any((doc) {
        final data = doc.data();
        final aDate = DateTime.parse(data['date']);

        final isSameDate = aDate.year == date.year &&
            aDate.month == date.month &&
            aDate.day == date.day;

        return isSameDate &&
            data['time'] == time &&
            data['status'] != 'cancelled';
      });
    } catch (e) {
      print('Erro ao verificar duplicidade: $e');
      return false; // Na dúvida, deixa passar (ou bloqueia, dependendo da regra)
    }
  }
  // -----------------------------------------------------

  // Criar Agendamento (Salva na nuvem)
  Future<void> createAppointment(Appointment appointment) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(appointment.id)
          .set(appointment.toMap());
    } catch (e) {
      throw Exception('Erro ao agendar: $e');
    }
  }

  // Atualizar Status (ex: Cancelar)
  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(appointmentId)
          .update({'status': status.name});
    } catch (e) {
      throw Exception('Erro ao atualizar status: $e');
    }
  }

  // Buscar Agendamentos do Usuário
  Stream<List<Appointment>> getAppointmentsStream(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots() // Atualiza em tempo real!
        .map((snapshot) => snapshot.docs
        .map((doc) => Appointment.fromMap(doc.data()))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date))); // Ordena por data
  }

  // Serviços Disponíveis (Estáticos por enquanto)
  List<Service> getAvailableServices() {
    return [
      Service(id: '1', type: ServiceType.bath, name: 'Banho', description: 'Banho completo', price: 50.0),
      Service(id: '2', type: ServiceType.grooming, name: 'Tosa', description: 'Tosa completa', price: 80.0),
      Service(id: '3', type: ServiceType.veterinary, name: 'Consulta Vet', description: 'Consulta geral', price: 150.0),
    ];
  }

  List<String> getAvailableTimes() {
    return ['08:00', '09:00', '10:00', '11:00', '14:00', '15:00', '16:00', '17:00'];
  }
}
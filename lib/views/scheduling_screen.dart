import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/appointment_controller.dart';
import '../controllers/pet_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/appointment.dart';
import '../models/service.dart';
import '../models/pet.dart';

class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({super.key});

  @override
  State<SchedulingScreen> createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {
  final _appointmentController = AppointmentController();
  final _petController = PetController();
  final _authController = AuthController();

  Pet? _selectedPet;
  Service? _selectedService;
  DateTime? _selectedDate;
  String? _selectedTime;

  List<Pet> _pets = [];
  List<Service> _services = [];
  String? _currentUserId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _authController.getCurrentUser();
    if (user == null) return;

    // Carrega pets do Firebase
    final petsList = await _petController.getPetsByUser(user.id);

    setState(() {
      _currentUserId = user.id;
      _pets = petsList;
      _services = _appointmentController.getAvailableServices();
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveAppointment() async {
    if (_selectedPet == null || _selectedService == null ||
        _selectedDate == null || _selectedTime == null || _currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // --- Verificação de Duplicidade no Firebase ---
    final isDuplicate = await _appointmentController.hasDuplicateAppointment(
      _selectedPet!.id,
      _selectedDate!,
      _selectedTime!,
    );

    if (isDuplicate) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('O pet ${_selectedPet!.name} já tem agendamento neste horário!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    // ---------------------------------------------

    try {
      final appointment = Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _currentUserId!,
        petId: _selectedPet!.id,
        serviceId: _selectedService!.id,
        date: _selectedDate!,
        time: _selectedTime!,
        createdAt: DateTime.now(),
      );

      await _appointmentController.createAppointment(appointment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento criado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar Serviço')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown de Pets
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selecione o Pet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (_pets.isEmpty)
                      const Text('Carregando pets ou nenhum cadastrado...')
                    else
                      DropdownButtonFormField<Pet>(
                        value: _selectedPet,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: _pets.map((pet) => DropdownMenuItem(value: pet, child: Text(pet.name))).toList(),
                        onChanged: (pet) => setState(() => _selectedPet = pet),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Dropdown de Serviços
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selecione o Serviço', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Service>(
                      value: _selectedService,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: _services.map((s) => DropdownMenuItem(value: s, child: Text('${s.name} - R\$ ${s.price.toStringAsFixed(2)}'))).toList(),
                      onChanged: (s) => setState(() => _selectedService = s),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Data
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selecione a Data', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _selectDate,
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                      child: Text(_selectedDate == null ? 'Escolher data' : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Horário
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selecione o Horário', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _appointmentController.getAvailableTimes().map((time) {
                        return ChoiceChip(
                          label: Text(time),
                          selected: _selectedTime == time,
                          onSelected: (sel) => setState(() => _selectedTime = sel ? time : null),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveAppointment,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading ? const CircularProgressIndicator() : const Text('Agendar'),
            ),
          ],
        ),
      ),
    );
  }
}
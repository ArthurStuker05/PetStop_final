import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../controllers/pet_controller.dart';
import '../controllers/appointment_controller.dart';
import '../models/pet.dart';
import '../models/appointment.dart';
import 'pet_profile_screen.dart';
import 'add_pet_screen.dart';
import 'scheduling_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _petController = PetController();
  final _authController = AuthController();
  final _appointmentController = AppointmentController();

  int _selectedIndex = 0;
  String? _currentUserId;

  List<Pet> _pets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final user = await _authController.getCurrentUser();

    if (user != null) {
      final petsList = await _petController.getPetsByUser(user.id);

      if (mounted) {
        setState(() {
          _currentUserId = user.id;
          _pets = petsList;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PetStop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authController.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: _selectedIndex == 0 ? _buildPetsList() : _buildAppointmentsList(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddPetScreen()),
          );
          _loadData();
        },
        child: const Icon(Icons.add),
      )
          : FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SchedulingScreen()),
          );
        },
        child: const Icon(Icons.calendar_today),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Meus Pets'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Agendamentos'),
        ],
      ),
    );
  }

  Widget _buildPetsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Nenhum pet cadastrado'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddPetScreen()),
                );
                _loadData();
              },
              child: const Text('Adicionar Pet'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pets.length,
        itemBuilder: (context, index) {
          final pet = _pets[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.pets, size: 40),
              title: Text(pet.name),
              subtitle: Text('${pet.breed} - ${pet.age} anos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PetProfileScreen(pet: pet)),
                );
                _loadData();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsList() {
    if (_currentUserId == null) return const Center(child: CircularProgressIndicator());

    return StreamBuilder<List<Appointment>>(
      stream: _appointmentController.getAppointmentsStream(_currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final appointments = snapshot.data ?? [];

        if (appointments.isEmpty) {
          return const Center(child: Text('Nenhum agendamento'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];

            final petName = _pets.firstWhere(
                    (p) => p.id == appointment.petId,
                orElse: () => Pet(id: '', userId: '', name: 'Pet não encontrado', breed: '', age: 0, weight: 0, createdAt: DateTime.now())
            ).name;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  _getStatusIcon(appointment.status),
                  color: _getStatusColor(appointment.status),
                ),


                // Agora: Data formatada + String da hora correta
                title: Text('${DateFormat('dd/MM').format(appointment.date)} - ${appointment.time}'),
                // ---------------------

                subtitle: Text('$petName - ${_getStatusText(appointment.status)}'),

                trailing: appointment.status != AppointmentStatus.cancelled
                    ? IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    await _appointmentController.updateAppointmentStatus(
                      appointment.id,
                      AppointmentStatus.cancelled,
                    );
                  },
                )
                    : const Icon(Icons.block, color: Colors.grey),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending: return Icons.pending;
      case AppointmentStatus.confirmed: return Icons.check_circle;
      case AppointmentStatus.completed: return Icons.done_all;
      case AppointmentStatus.cancelled: return Icons.cancel;
    }
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending: return Colors.orange;
      case AppointmentStatus.confirmed: return Colors.cyan;
      case AppointmentStatus.completed: return Colors.pink;
      case AppointmentStatus.cancelled: return Colors.grey;
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending: return 'Pendente';
      case AppointmentStatus.confirmed: return 'Confirmado';
      case AppointmentStatus.completed: return 'Concluído';
      case AppointmentStatus.cancelled: return 'Cancelado';
    }
  }
}
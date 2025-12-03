import 'package:flutter/material.dart';
import '../controllers/pet_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/pet.dart';

class AddPetScreen extends StatefulWidget {
  final Pet? pet;

  const AddPetScreen({super.key, this.pet});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto básicos
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _medicalNotesController = TextEditingController();

  // Controladores para os itens de lista
  final _vaccineController = TextEditingController();
  final _allergyController = TextEditingController();

  final _petController = PetController();
  final _authController = AuthController();

  bool _isLoading = false;
  String? _currentUserId;

  // Listas locais para armazenar vacinas e alergias
  List<String> _vaccines = [];
  List<String> _allergies = [];

  @override
  void initState() {
    super.initState();
    _loadUser();

    // Se for edição, preenche os campos com os dados existentes
    if (widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _breedController.text = widget.pet!.breed;
      _ageController.text = widget.pet!.age.toString();
      _weightController.text = widget.pet!.weight.toString();
      _medicalNotesController.text = widget.pet!.medicalNotes;

      // Carrega as listas existentes
      _vaccines = List.from(widget.pet!.vaccines);
      _allergies = List.from(widget.pet!.allergies);
    }
  }

  Future<void> _loadUser() async {
    final user = await _authController.getCurrentUser();
    setState(() {
      _currentUserId = user?.id;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _medicalNotesController.dispose();
    _vaccineController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  // Métodos para adicionar/remover itens das listas
  void _addItem(List<String> list, TextEditingController controller) {
    if (controller.text.trim().isNotEmpty) {
      setState(() {
        list.add(controller.text.trim());
        controller.clear();
      });
    }
  }

  void _removeItem(List<String> list, int index) {
    setState(() {
      list.removeAt(index);
    });
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate() || _currentUserId == null) return;

    setState(() => _isLoading = true);

    try {
      final pet = Pet(
        id: widget.pet?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _currentUserId!,
        name: _nameController.text.trim(),
        breed: _breedController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        weight: double.parse(_weightController.text.trim()),
        medicalNotes: _medicalNotesController.text.trim(),
        // Agora salvamos as listas preenchidas
        vaccines: _vaccines,
        allergies: _allergies,
        createdAt: widget.pet?.createdAt ?? DateTime.now(),
      );

      if (widget.pet != null) {
        await _petController.updatePet(pet);
      } else {
        await _petController.createPet(pet);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Widget auxiliar para criar o campo de entrada com lista
  Widget _buildListInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required List<String> items,
    required VoidCallback onAdd,
    required Function(int) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyan)),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  border: const UnderlineInputBorder(),
                ),
                onFieldSubmitted: (_) => onAdd(), // Adiciona ao apertar Enter
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.pinkAccent),
              onPressed: onAdd,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: items.asMap().entries.map((entry) {
            return Chip(
              label: Text(entry.value),
              backgroundColor: Colors.cyan[50],
              deleteIcon: const Icon(Icons.close, size: 18, color: Colors.pinkAccent),
              onDeleted: () => onRemove(entry.key),
              side: BorderSide.none,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet == null ? 'Adicionar Pet' : 'Editar Pet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Dados Básicos ---
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.pets, color: Colors.cyan),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Digite o nome' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _breedController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Raça',
                  prefixIcon: Icon(Icons.category, color: Colors.cyan),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Digite a raça' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Idade',
                        suffixText: 'anos',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Digite a idade';
                        if (int.tryParse(value) == null) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Peso',
                        suffixText: 'kg',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Digite o peso';
                        if (double.tryParse(value) == null) return 'Inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Vacinas ---
              _buildListInput(
                label: 'Vacinas',
                hint: 'Ex: Raiva, V10...',
                controller: _vaccineController,
                items: _vaccines,
                onAdd: () => _addItem(_vaccines, _vaccineController),
                onRemove: (index) => _removeItem(_vaccines, index),
              ),
              const SizedBox(height: 24),

              // --- Alergias ---
              _buildListInput(
                label: 'Alergias',
                hint: 'Ex: Frango, Pólen...',
                controller: _allergyController,
                items: _allergies,
                onAdd: () => _addItem(_allergies, _allergyController),
                onRemove: (index) => _removeItem(_allergies, index),
              ),
              const SizedBox(height: 24),

              // --- Observações ---
              TextFormField(
                controller: _medicalNotesController,
                decoration: const InputDecoration(
                  labelText: 'Observações Médicas',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _savePet,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.pet == null ? 'Salvar Pet' : 'Atualizar Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
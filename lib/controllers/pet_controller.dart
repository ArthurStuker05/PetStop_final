import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet.dart';

class PetController {
  // Instância do Banco de Dados na Nuvem
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'pets';

  // Salvar Pet no Firebase
  Future<void> createPet(Pet pet) async {
    try {
      // Salva usando o ID do pet como nome do documento
      await _firestore.collection(_collection).doc(pet.id).set(pet.toMap());
    } catch (e) {
      throw Exception('Erro ao salvar pet na nuvem: $e');
    }
  }

  // Atualizar Pet
  Future<void> updatePet(Pet pet) async {
    try {
      await _firestore.collection(_collection).doc(pet.id).update(pet.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar pet: $e');
    }
  }

  // Deletar Pet
  Future<void> deletePet(String petId) async {
    try {
      await _firestore.collection(_collection).doc(petId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar pet: $e');
    }
  }

  // Buscar Pets do Usuário (Retorna a lista direto da nuvem)
  Future<List<Pet>> getPetsByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => Pet.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Erro ao buscar pets: $e');
      return [];
    }
  }

  // Buscar um pet específico
  Future<Pet?> getPetById(String petId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(petId).get();
      if (doc.exists) {
        return Pet.fromMap(doc.data()!);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
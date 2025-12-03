import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Verifica se já tem alguém logado ao abrir o app
  Future<app_user.User?> getCurrentUser() async {
    final User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      // Tenta buscar os dados extras no Firestore
      return await _getUserData(firebaseUser.uid) ??
          // Se não achar no banco (ex: criou via console), retorna um básico
          app_user.User(id: firebaseUser.uid, email: firebaseUser.email!, name: '');
    }
    return null;
  }

  // Login (Entrar)
  Future<app_user.User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return await _getUserData(credential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      // Traduzindo os erros do Firebase para português
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        throw Exception('Email ou senha incorretos.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Senha incorreta.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Email inválido.');
      }
      throw Exception('Erro no login: ${e.message}');
    }
    return null;
  }

  // Cadastro (Registrar)
  Future<app_user.User?> signUp(String email, String password, String name) async {
    try {
      // 1. Cria a conta no Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Salva o nome e email no banco de dados (Firestore)
      if (credential.user != null) {
        final newUser = app_user.User(
          id: credential.user!.uid,
          email: email,
          name: name,
        );

        await _firestore
            .collection('users')
            .doc(newUser.id)
            .set(newUser.toMap());

        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Este email já está cadastrado.');
      } else if (e.code == 'weak-password') {
        throw Exception('A senha deve ter pelo menos 6 caracteres.');
      }
      throw Exception('Erro no cadastro: ${e.message}');
    }
    return null;
  }

  // Sair
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Auxiliar para buscar dados do Firestore
  Future<app_user.User?> _getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return app_user.User.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Erro ao buscar dados: $e');
    }
    return null;
  }
}
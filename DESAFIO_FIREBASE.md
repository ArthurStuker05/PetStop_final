# 🔥 Desafio: Implementação do Firebase

Este documento contém um guia passo a passo para migrar o PetStop de armazenamento local para Firebase.

## 📋 Índice

1. [Configuração Inicial](#1-configuração-inicial)
2. [Firebase Authentication](#2-firebase-authentication)
3. [Cloud Firestore](#3-cloud-firestore)
4. [Firebase Cloud Messaging](#4-firebase-cloud-messaging)
5. [Firebase Storage](#5-firebase-storage)
6. [Checklist de Implementação](#checklist-de-implementação)

---

## 1. Configuração Inicial

### 1.1 Criar Projeto no Firebase Console

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto"
3. Nome do projeto: `petstop-mobile` (ou outro nome de sua escolha)
4. Desabilite Google Analytics (ou habilite se preferir)
5. Clique em "Criar projeto"

### 1.2 Adicionar Apps ao Projeto

#### Android:
1. No Firebase Console, clique no ícone Android
2. Package name: `com.example.petstop` (ou o package do seu app)
3. Baixe o arquivo `google-services.json`
4. Coloque em: `android/app/google-services.json`

#### iOS:
1. No Firebase Console, clique no ícone iOS
2. Bundle ID: `com.example.petstop` (ou o bundle do seu app)
3. Baixe o arquivo `GoogleService-Info.plist`
4. Coloque em: `ios/Runner/GoogleService-Info.plist`

#### Web:
1. No Firebase Console, clique no ícone Web
2. Registre o app
3. Copie as credenciais de configuração

### 1.3 Instalar FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 1.4 Configurar Firebase no Projeto Flutter

```bash
cd petstop
flutterfire configure
```

Siga as instruções:
- Selecione o projeto Firebase criado
- Selecione as plataformas (Android, iOS, Web)
- O arquivo `lib/firebase_options.dart` será gerado automaticamente

### 1.5 Adicionar Dependências

Atualize o `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_messaging: ^15.1.3
  firebase_storage: ^12.3.0
  intl: ^0.19.0
```

Execute:
```bash
flutter pub get
```

### 1.6 Configurar Android

No arquivo `android/app/build.gradle`, adicione:

```gradle
dependencies {
    // ... outras dependências
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
}
```

No arquivo `android/build.gradle`, adicione:

```gradle
buildscript {
    dependencies {
        // ... outras dependências
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### 1.7 Configurar iOS

No arquivo `ios/Podfile`, adicione no início:

```ruby
platform :ios, '13.0'
```

Execute:
```bash
cd ios
pod install
cd ..
```

---

## 2. Firebase Authentication

### 2.1 Habilitar Authentication no Console

1. No Firebase Console, vá em "Authentication"
2. Clique em "Começar"
3. Habilite "Email/Password"
4. Salve

### 2.2 Migrar AuthController

Substitua o conteúdo de `lib/controllers/auth_controller.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<app_user.User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _getUserData(credential.user?.uid ?? '');
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  Future<app_user.User?> signUp(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = app_user.User(
        id: credential.user?.uid ?? '',
        email: email,
        name: name,
      );
      
      await _firestore.collection('users').doc(user.id).set(user.toMap());
      return user;
    } catch (e) {
      throw Exception('Erro ao criar conta: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<app_user.User?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _getUserData(user.uid);
    }
    return null;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<app_user.User?> _getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return app_user.User.fromMap(doc.data()!);
    }
    return null;
  }
}
```

### 2.3 Atualizar main.dart

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PetStopApp());
}
```

---

## 3. Cloud Firestore

### 3.1 Criar Banco de Dados

1. No Firebase Console, vá em "Firestore Database"
2. Clique em "Criar banco de dados"
3. Escolha modo de produção (ou modo de teste para desenvolvimento)
4. Escolha a localização (ex: southamerica-east1 para Brasil)

### 3.2 Estrutura de Coleções

Crie as seguintes coleções:

#### users
```
users/{userId}
  - id: string
  - email: string
  - name: string
  - createdAt: timestamp
```

#### pets
```
pets/{petId}
  - id: string
  - userId: string
  - name: string
  - breed: string
  - age: number
  - weight: number
  - vaccines: array<string>
  - allergies: array<string>
  - medicalNotes: string
  - createdAt: timestamp
```

#### appointments
```
appointments/{appointmentId}
  - id: string
  - userId: string
  - petId: string
  - serviceId: string
  - date: timestamp
  - time: string
  - status: string (pending, confirmed, completed, cancelled)
  - createdAt: timestamp
```

#### services
```
services/{serviceId}
  - id: string
  - type: string (bath, grooming, veterinary)
  - name: string
  - description: string
  - price: number
```

### 3.3 Migrar PetController

Substitua `lib/controllers/pet_controller.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet.dart';

class PetController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPet(Pet pet) async {
    try {
      await _firestore.collection('pets').doc(pet.id).set(pet.toMap());
    } catch (e) {
      throw Exception('Erro ao criar pet: $e');
    }
  }

  Future<void> updatePet(Pet pet) async {
    try {
      await _firestore.collection('pets').doc(pet.id).update(pet.toMap());
    } catch (e) {
      throw Exception('Erro ao atualizar pet: $e');
    }
  }

  Future<void> deletePet(String petId) async {
    try {
      await _firestore.collection('pets').doc(petId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar pet: $e');
    }
  }

  Stream<List<Pet>> getPetsByUser(String userId) {
    return _firestore
        .collection('pets')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pet.fromMap(doc.data()))
            .toList());
  }

  Future<Pet?> getPetById(String petId) async {
    try {
      final doc = await _firestore.collection('pets').doc(petId).get();
      if (doc.exists) {
        return Pet.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar pet: $e');
    }
  }
}
```

### 3.4 Migrar AppointmentController

Substitua `lib/controllers/appointment_controller.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';
import '../models/service.dart';

class AppointmentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createAppointment(Appointment appointment) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .set(appointment.toMap());
    } catch (e) {
      throw Exception('Erro ao criar agendamento: $e');
    }
  }

  Future<void> updateAppointmentStatus(
      String appointmentId, AppointmentStatus status) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({'status': status.name});
    } catch (e) {
      throw Exception('Erro ao atualizar agendamento: $e');
    }
  }

  Stream<List<Appointment>> getAppointmentsByUser(String userId) {
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap(doc.data()))
            .toList());
  }

  Future<List<Service>> getAvailableServices() async {
    try {
      final snapshot = await _firestore.collection('services').get();
      if (snapshot.docs.isEmpty) {
        return _getDefaultServices();
      }
      return snapshot.docs
          .map((doc) => Service.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return _getDefaultServices();
    }
  }

  List<Service> _getDefaultServices() {
    return [
      Service(
        id: '1',
        type: ServiceType.bath,
        name: 'Banho',
        description: 'Banho completo para seu pet',
        price: 50.0,
      ),
      Service(
        id: '2',
        type: ServiceType.grooming,
        name: 'Tosa',
        description: 'Tosa completa para seu pet',
        price: 80.0,
      ),
      Service(
        id: '3',
        type: ServiceType.veterinary,
        name: 'Consulta Veterinária',
        description: 'Consulta com veterinário',
        price: 150.0,
      ),
    ];
  }

  List<String> getAvailableTimes() {
    return [
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
    ];
  }
}
```

### 3.5 Regras de Segurança do Firestore

No Firebase Console, vá em Firestore > Regras e configure:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Regras para usuários
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Regras para pets
    match /pets/{petId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Regras para agendamentos
    match /appointments/{appointmentId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Regras para serviços
    match /services/{serviceId} {
      allow read: if request.auth != null;
      allow write: if false; // Apenas leitura
    }
  }
}
```

---

## 4. Firebase Cloud Messaging

### 4.1 Configurar FCM

#### Android:
1. No Firebase Console, vá em Project Settings > Cloud Messaging
2. Copie a Server Key
3. Configure no `AndroidManifest.xml`:

```xml
<service
    android:name="com.google.firebase.messaging.FirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

#### iOS:
1. No Apple Developer, gere um certificado APNs
2. Faça upload no Firebase Console
3. Configure no `AppDelegate.swift`

### 4.2 Implementar Notificações

Crie `lib/services/notification_service.dart`:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken();
      print('FCM Token: $token');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificação recebida: ${message.notification?.title}');
    });
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}
```

---

## 5. Firebase Storage

### 5.1 Habilitar Storage

1. No Firebase Console, vá em "Storage"
2. Clique em "Começar"
3. Escolha as regras de segurança
4. Escolha a localização

### 5.2 Implementar Upload de Fotos

```dart
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPetPhoto(File imageFile, String petId) async {
    try {
      final ref = _storage.ref().child('pets/$petId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erro ao fazer upload: $e');
    }
  }
}
```

---

## Checklist de Implementação

### Fase 1: Configuração ✅
- [ ] Criar projeto no Firebase Console
- [ ] Configurar apps (Android, iOS, Web)
- [ ] Instalar FlutterFire CLI
- [ ] Executar `flutterfire configure`
- [ ] Adicionar dependências no `pubspec.yaml`
- [ ] Configurar arquivos de configuração (google-services.json, etc.)

### Fase 2: Authentication ✅
- [ ] Habilitar Email/Password no Firebase Console
- [ ] Migrar `AuthController` para Firebase Auth
- [ ] Atualizar `main.dart` para inicializar Firebase
- [ ] Testar login e cadastro
- [ ] Implementar recuperação de senha

### Fase 3: Firestore ✅
- [ ] Criar banco de dados Firestore
- [ ] Criar coleções (users, pets, appointments, services)
- [ ] Migrar `PetController` para Firestore
- [ ] Migrar `AppointmentController` para Firestore
- [ ] Configurar regras de segurança
- [ ] Implementar listeners em tempo real
- [ ] Atualizar views para usar Streams

### Fase 4: Notificações ✅
- [ ] Configurar FCM no Firebase Console
- [ ] Implementar `NotificationService`
- [ ] Configurar Android (AndroidManifest.xml)
- [ ] Configurar iOS (certificado APNs)
- [ ] Criar notificações para novos agendamentos
- [ ] Criar lembretes de vacinas

### Fase 5: Storage ✅
- [ ] Habilitar Firebase Storage
- [ ] Implementar upload de fotos dos pets
- [ ] Adicionar seleção de imagem nas telas
- [ ] Exibir fotos dos pets

### Fase 6: Funcionalidades Extras ✅
- [ ] Implementar chat (coleção `messages` no Firestore)
- [ ] Adicionar sistema de avaliações
- [ ] Criar filtros e buscas
- [ ] Implementar paginação
- [ ] Adicionar analytics

---

## 📚 Recursos Adicionais

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

**Boa sorte com a implementação! 🚀**


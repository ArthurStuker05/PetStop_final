# PetStop - Aplicativo Mobile

**Curso:** TI para Negócios Digitais  
**Instituição:** PUC Campinas  
**Disciplina:** Desenvolvimento Mobile  
**Ano:** 2025

## 📱 Sobre o Projeto

PetStop é um aplicativo móvel desenvolvido em Flutter para gerenciamento de perfis de pets e agendamento de serviços. O projeto foi desenvolvido como base educacional para que os alunos possam aprimorar e implementar funcionalidades adicionais.

## 🎯 Funcionalidades Implementadas

- ✅ Cadastro e autenticação de usuários (armazenamento local)
- ✅ Cadastro de múltiplos pets por usuário
- ✅ Visualização e edição de perfis de pets
- ✅ Agendamento de serviços (banho, tosa, consulta veterinária)
- ✅ Lista de agendamentos
- ✅ Histórico de serviços

## 🛠️ Tecnologias Utilizadas

- **Flutter** - Framework multiplataforma
- **Dart** - Linguagem de programação
- **SharedPreferences** - Armazenamento local
- **Material Design 3** - Design system

## 📋 Pré-requisitos

- Flutter SDK (versão 3.8.1 ou superior)
- Dart SDK
- Android Studio / VS Code com extensões Flutter
- Git

## 🚀 Como Executar

1. Clone o repositório:
```bash
git clone git@github.com:douglashsabreu/PetStop_mobile_2025.git
cd PetStop_mobile_2025/petstop
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o aplicativo:
```bash
flutter run
```

## 📁 Estrutura do Projeto

```
lib/
├── controllers/          # Lógica de negócio
│   ├── auth_controller.dart
│   ├── pet_controller.dart
│   └── appointment_controller.dart
├── models/              # Modelos de dados
│   ├── user.dart
│   ├── pet.dart
│   ├── service.dart
│   └── appointment.dart
├── services/            # Serviços auxiliares
│   └── local_storage.dart
├── views/               # Telas do aplicativo
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── add_pet_screen.dart
│   ├── pet_profile_screen.dart
│   └── scheduling_screen.dart
└── main.dart           # Ponto de entrada
```

## 🎓 Desafios e Próximas Etapas

### 🔥 Desafio Principal: Implementar Firebase

O projeto atual utiliza armazenamento local. O desafio é migrar para Firebase, implementando:

#### 1. Configuração do Firebase
- [ ] Criar projeto no Firebase Console
- [ ] Configurar Firebase Authentication
- [ ] Configurar Cloud Firestore
- [ ] Executar `flutterfire configure` no projeto
- [ ] Adicionar dependências Firebase no `pubspec.yaml`

#### 2. Autenticação com Firebase
- [ ] Migrar `AuthController` para usar `FirebaseAuth`
- [ ] Implementar login com email/senha
- [ ] Implementar cadastro de usuários
- [ ] Adicionar recuperação de senha
- [ ] Implementar logout

#### 3. Firestore Database
- [ ] Criar coleções no Firestore:
  - `users` - Dados dos usuários
  - `pets` - Perfis dos pets
  - `appointments` - Agendamentos
  - `services` - Serviços disponíveis
- [ ] Migrar `PetController` para usar Firestore
- [ ] Migrar `AppointmentController` para usar Firestore
- [ ] Implementar listeners em tempo real (Streams)
- [ ] Adicionar regras de segurança no Firestore

#### 4. Notificações Push (Firebase Cloud Messaging)
- [ ] Configurar FCM no projeto
- [ ] Implementar notificações para novos agendamentos
- [ ] Criar lembretes de vacinas
- [ ] Notificar mudanças de status de agendamento

#### 5. Funcionalidades Adicionais
- [ ] Implementar chat entre usuário e prestadores (Cloud Firestore)
- [ ] Adicionar upload de fotos dos pets (Firebase Storage)
- [ ] Implementar histórico detalhado de serviços
- [ ] Criar sistema de avaliações
- [ ] Adicionar filtros e buscas avançadas

### 📚 Recursos de Aprendizado

- [Documentação Flutter](https://docs.flutter.dev/)
- [Firebase para Flutter](https://firebase.flutter.dev/)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)

## 📝 Requisitos Funcionais

### Implementados ✅
- RF01 - Cadastro e autenticação de usuários
- RF02 - Cadastro de múltiplos pets por usuário
- RF03 - Agendamento de serviços
- RF05 - Histórico de serviços
- RF07 - Atualização de informações do pet

### Pendentes 🔄
- RF04 - Notificações automáticas (desafio Firebase)
- RF06 - Chat entre usuário e prestadores (desafio Firebase)

## 👥 Autores

**Alunos:**
- Matheus Franco
- Arthur Stucker

**Professor:**
- Douglas Abreu

## 📄 Licença

Este projeto está licenciado sob a MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🤝 Contribuindo

Este é um projeto educacional. Sinta-se à vontade para:
- Reportar bugs
- Sugerir melhorias
- Implementar novas funcionalidades
- Compartilhar conhecimento

---

**Desenvolvido para a disciplina de Desenvolvimento Mobile - PUC Campinas 2025**

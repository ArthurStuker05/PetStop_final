# 🐾 PetStop Mobile

> Aplicativo mobile para gerenciamento completo de serviços veterinários e petshops, desenvolvido com **Flutter** e **Firebase**. Foco em reatividade em tempo real, arquitetura MVC limpa e experiência de usuário.

---

## 🚀 Tecnologias e Stack

*   **[Flutter](https://flutter.dev/)** – Framework de UI nativa e reativa (suporte Mobile configurado via `kIsWeb`).
*   **[Dart](https://dart.dev/)** – Linguagem principal com forte tipagem e null-safety.
*   **[Firebase Authentication](https://firebase.google.com/docs/auth)** – Sistema de login e cadastro com tratamento nativo de exceções e tradução de erros para o usuário.
*   **[Cloud Firestore](https://firebase.google.com/docs/firestore)** – Banco de dados NoSQL real-time para sincronização imediata de agendamentos e cadastros.


---

## 🧠 Arquitetura: Padrão MVC

O projeto segue estritamente o padrão **Model-View-Controller**, isolando a regra de negócios da interface gráfica e do banco de dados:

*   **Models:** Classes blindadas (`User`, `Pet`, `Appointment`, `Service`) equipadas com métodos de serialização `toMap()` e `fromMap()`, garantindo o trânsito seguro de dados com a nuvem.
*   **Controllers:** 
    *   `AuthController`: Interceptação inteligente de erros do Firebase.
    *   `PetController`: CRUD completo otimizado na coleção `pets`.
    *   `AppointmentController`: Lógica avançada para prevenir sobreposição e duplicidade de horários na agenda, além de fornecer um `Stream` reativo para a UI.

---

## ✨ Features de Destaque

- [x] **Agendamentos em Tempo Real:** Telas que se atualizam sozinhas quando o status do agendamento muda (Pendente ➡️ Confirmado) usando `snapshots()`.
- [x] **Prevenção de Conflitos:** Função nativa no Controller que impede a marcação duplicada para o mesmo pet no mesmo horário.
- [x] **Inicialização Inteligente:** Detecção de plataforma (Android/iOS vs Web) no `main.dart` para rotear as credenciais corretas do Firebase sem quebrar a compilação.

---

## 🛠️ Como Executar o Projeto

### Pré-requisitos
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.
*   Emulador Android/iOS configurado ou navegador Chrome para versão Web.

### 1. Clonar o Repositório
```bash
git clone https://github.com/ArthurStuker05/PetStop_Mobile.git
cd PetStop_Mobile
```

### 2. Instalar as Dependências
```bash
flutter pub get
```

### 3. Executar o App
```bash
# Para rodar no dispositivo padrão (Emulador ou Web)
flutter run
```

---

## 🐶 Exemplo de Estrutura de Dados (Firestore)

Quando um novo pet é cadastrado na plataforma, o `PetController` processa o objeto e o envia estruturado para a nuvem. 

**Exemplo de carga (Payload):**
```json
{
  "id": "abc-123",
  "userId": "user-789",
  "name": "Buddy",
  "breed": "Yorkshire Terrier",
  "age": 3,
  "weight": 4.5,
  "vaccines": ["Antirrábica", "V10"],
  "allergies": [],
  "createdAt": "2026-07-05T10:00:00Z"
}
```

---

## 👤 Autor

Desenvolvido por **Arthur Trajano Stüker**, com o auxílio do docente **Douglas Abreu** 🚀
*   **GitHub:** [@ArthurStuker05](https://github.com/ArthurStuker05)

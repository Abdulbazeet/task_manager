# Flutter Mobile App - Setup & Architecture

Complete mobile task management app built with Flutter and Riverpod state management.

**✨ Tech Stack:**
- Flutter 3.x + Dart 3.x
- Riverpod 3.3.1 (AsyncNotifier pattern)
- GoRouter 17.2.0 (navigation)
- flutter_secure_storage (secure token storage)
- file_picker (file selection)

---

## 📱 Prerequisites

- Flutter SDK 3.0+
- Dart 3.0+
- Android emulator or iOS simulator (or physical device)

**Check Installation:**
```bash
flutter doctor
```

---

## 🚀 Setup Instructions

### 1. Get Dependencies

```bash
flutter pub get
```

### 2. Configure API Base URL

Edit `lib/services/repository/auth_repository.dart` and `lib/services/repository/task_repository.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
// static const String baseUrl = 'http://localhost:8000/api'; // iOS/Physical device
```

**IP Mapping:**
- **Android Emulator**: `10.0.2.2:8000` (Android special alias for localhost)
- **iOS Simulator**: `localhost:8000`
- **Physical Device**: Your machine's IP (e.g., `192.168.1.100:8000`)

### 3. Run the App

```bash
flutter run
```

Or with specific device:
```bash
flutter run -d <device_id>
```

---

## 🏗️ Project Architecture

### Folder Structure

```
lib/
├── main.dart                      # App entry point
│
├── presentation/                  # UI Screens (MVVM pattern)
│   ├── home/
│   │   └── screen/home.dart
│   ├── sign_in/
│   │   └── screen/sign_in.dart
│   ├── sign_up/
│   │   └── screen/sign_up.dart
│   ├── create_tasks/
│   │   └── screen/create_task.dart
│   └── edit/
│       └── screen/edit_screen.dart
│
├── services/                      # Business Logic
│   ├── repository/               # Data Layer (API calls)
│   │   ├── auth_repository.dart
│   │   └── task_repository.dart
│   └── controllers/              # State Management (Riverpod)
│       ├── auth_controller.dart
│       └── tasks_controller.dart
│
├── config/                        # Configuration
│   ├── routes.dart               # GoRouter setup
│   ├── theme.dart                # Material theme
│   ├── utils.dart                # Utility functions
│   └── exception.dart            # Error handling
│
├── core/                          # Core Utilities
│   └── token_manager.dart        # JWT token persistence
│
├── models/                        # Data Models
│   ├── user.dart
│   ├── task.dart
│   └── file_attachment.dart
│
└── widget/                        # Custom Widgets
    ├── task_list.dart
    └── text_field.dart
```

---

## 🔄 State Management (Riverpod)

### AuthController
Manages user authentication state with JWT token persistence.

**Type:** `AsyncNotifier<User?>`

**Methods:**
- `login(email, password)` - Authenticate user
- `register(name, email, password, passwordConfirmation)` - Create account
- `logout()` - Clear authentication
- `restoreSession()` - Auto-restore on app launch

**Usage in UI:**
```dart
final authState = ref.watch(authProvider);

authState.when(
  data: (user) => user != null ? HomeScreen() : LoginScreen(),
  loading: () => LoadingScreen(),
  error: (err, st) => ErrorScreen(error: err),
);
```

---

### TasksController
Manages task list and CRUD operations.

**Type:** `AsyncNotifier<List<Task>>`

**Methods:**
- `fetchTasks({status, priority})` - Get all tasks
- `createTask(...)` - Add new task
- `updateTask(id, ...)` - Edit task
- `deleteTask(id)` - Remove task
- `uploadFile(taskId, file)` - Attach file

**Usage in UI:**
```dart
final tasksState = ref.watch(tasksProvider);

tasksState.when(
  data: (tasks) => TaskListView(tasks: tasks),
  loading: () => SkeletonLoader(),
  error: (err, st) => ErrorWidget(error: err),
);
```

---

## 📋 Repository Pattern

### AuthRepository
Raw HTTP calls for authentication.

```dart
class AuthRepository {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // POST /auth/login
    // Saves token to TokenManager
    // Returns user data
  }
}
```

### TaskRepository
Raw HTTP calls for task management with multipart file upload support.

```dart
class TaskRepository {
  Future<List<Task>> getTasks({
    String? status,
    String? priority,
  }) async {
    // GET /tasks?status=...&priority=...
  }

  Future<FileAttachment> attachFile(int taskId, File file) async {
    // POST /tasks/{taskId}/attach-file (multipart)
  }
}
```

---

## 🔐 Authentication Flow

### 1. Login/Register
```
User Input → AuthController → AuthRepository → Backend
  ↓
Save JWT Token → TokenManager (flutter_secure_storage)
  ↓
Navigate to Home Screen
```

### 2. API Requests
```
Every request includes Authorization header:
"Authorization: Bearer {jwt_token}"
```

### 3. Token Restoration on App Launch
```
App Start → AuthController.build()
  ↓
Check TokenManager.hasToken()
  ↓
If exists: Call getMe() to restore session
  ↓
Set authProvider to logged-in user OR null
```

---

## 📱 Screens Overview

### Sign In Screen (`sign_in.dart`)
- Email and password inputs
- Error message display
- Navigation to Sign Up
- Auto-restores session on app launch

### Sign Up Screen (`sign_up.dart`)
- Name, email, password inputs
- Real-time password match validation
- Confirm account creation
- Navigation to Sign In after success

### Home/Task List Screen (`home.dart`)
- Tab-based filtering (All, Pending, In Progress, Done)
- Task count badges
- Pull-to-refresh
- FAB to create task
- Logout option

### Create Task Screen (`create_task.dart`)
- Title, description inputs
- Priority selector (Low, Medium, High)
- Due date picker
- File attachment picker
- Upload file after task creation

### Edit Task Screen (`edit_screen.dart`)
- View/edit all task fields
- Status selector (Pending, In Progress, Done)
- File attachment option
- Update or delete task

### Task List Widget (`task_list.dart`)
- Display filtered tasks
- Mark as done/undone
- Delete with confirmation dialog
- Navigate to edit screen
- Show priority/due date badges

---

## 🔌 API Integration

### Base URL Configuration

**Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

**Physical Device:**
```dart
// Get your machine IP
static const String baseUrl = 'http://192.168.1.100:8000/api'; // Replace with your IP
```

### Making Requests

**Example: Login**
```dart
Future<void> login({required String email, required String password}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['data'];
    await TokenManager.saveToken(data['token']);
    return User.fromJson(data);
  }
}
```

---

## 🛠️ Debugging

### View Logs
```bash
flutter logs
```

### Debug Mode
```bash
flutter run --debug
```

### Release Mode
```bash
flutter run --release
```

### Check API Connectivity
```dart
// In controller/widget
print('API URL: $baseUrl');
print('Token: ${await TokenManager.getToken()}');
```

---

## 🚢 Build & Deployment

### Android APK
```bash
flutter build apk --release
```

### iOS App
```bash
flutter build ios --release
```

### Web
```bash
flutter build web
```

---

## 📦 Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | 3.3.1 | State management |
| go_router | 17.2.0 | Navigation |
| flutter_secure_storage | 9.2.2 | Secure token storage |
| http | latest | HTTP requests |
| file_picker | latest | File selection |
| intl | latest | Date/time formatting |

---

## 🎯 Best Practices Used

✅ **Separation of Concerns**
- Presentation (UI), Business Logic (Controllers), Data (Repository)

✅ **State Management**
- AsyncNotifier for async operations
- Proper loading/error/data states

✅ **Error Handling**
- ApiException for API errors
- User-friendly error messages

✅ **Security**
- Secure token storage (flutter_secure_storage)
- JWT authentication
- No sensitive data in code

✅ **Code Organization**
- Feature-based folder structure
- Reusable widgets
- Utility functions centralized

---

## 📝 License

This project is open source and available under the MIT license.

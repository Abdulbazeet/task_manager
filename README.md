# Task Manager - Complete Task Management System

A full-stack task management application with a **Flutter mobile app** and **Laravel REST API** backend. Complete CRUD operations, user authentication, file attachments, and real-time task filtering.

**✨ Features:**

- 🔐 JWT Authentication with secure token storage
- ✅ Full Task CRUD operations
- 📎 File attachments (max 2MB)
- 🎯 Task filtering by status & priority
- 📱 Beautiful Flutter UI with Riverpod state management
- 🔄 Pull-to-refresh functionality
- 🌙 Dark/Light theme support
- ⚡ Real-time validation

---

## 📁 Project Structure

```
task_manager/
├── task-manager_backend/          # Laravel API
│   ├── app/
│   │   ├── Http/Controllers/      # API Controllers
│   │   ├── Models/                # Eloquent Models (User, Task, FileAttachment)
│   │   └── Http/Requests/         # Form validation
│   ├── database/
│   │   ├── migrations/            # Database schema
│   │   └── seeders/               # Sample data
│   ├── routes/api.php             # API endpoints
│   ├── .env.example               # Environment template
│   └── README.md                  # Backend setup guide
│
├── lib/                           # Flutter App
│   ├── presentation/              # UI screens
│   │   ├── home/
│   │   ├── sign_in/
│   │   ├── sign_up/
│   │   ├── create_tasks/
│   │   └── edit/
│   ├── services/
│   │   ├── repository/            # API layer
│   │   └── controllers/           # State management
│   ├── models/                    # Data models
│   ├── config/                    # Routes, theme, utils
│   └── core/                      # Token manager
│
├── pubspec.yaml                   # Flutter dependencies
└── README.md                       # This file
```

---

## 🚀 Quick Start

### Backend Setup

```bash
cd task-manager_backend
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate:fresh --seed
php artisan serve
```


---

## 📱 App Screenshots

### Authentication Screens

**Sign In**
![Sign In Screen](docs/screenshots/01_signin.png)

**Sign Up**
![Sign Up Screen](docs/screenshots/02_signup.png)

### Task Management

**Task List** - View all tasks with status badges
![Task List](docs/screenshots/03_tasklist.png)

**Create Task** - Add new task with file attachment
![Create Task](docs/screenshots/04_create_task.png)

**Edit Task** - Modify task details and status
![Edit Task](docs/screenshots/05_edit_task.png)

**Edit Task** - Full view with attachment option
![Edit Task Full](docs/screenshots/06_edit_task_full.png)

---

## 🛠️ Tech Stack

| Layer                | Technology                     |
| -------------------- | ------------------------------ |
| **Frontend**         | Flutter 3.x, Dart 3.x          |
| **State Management** | Riverpod 3.3.1 (AsyncNotifier) |
| **Backend**          | Laravel 11.x                   |
| **Database**         | MySQL 8.x                      |
| **Authentication**   | JWT (Tymon/jwt-auth)           |
| **Storage**          | Local + S3 compatible          |

---


## 🔗 Live Repository

👉 [github.com/Abdulbazeet/task_manager](https://github.com/Abdulbazeet/task_manager)

---

## 📝 License

This project is open source and available under the MIT license.

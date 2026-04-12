# Task Manager - Laravel REST API

A production-ready REST API built with Laravel 11 for complete task management with JWT authentication, file attachments, and advanced filtering.

**✨ Features:**

- 🔐 JWT-based authentication (Tymon/jwt-auth)
- ✅ Complete Task CRUD with validation
- 📎 File attachment management (max 2MB)
- 🎯 Advanced filtering (status, priority)
- 📊 Pagination support
- 📊 Comprehensive error handling
- 🗄️ MySQL database with migrations

---

## 📋 Prerequisites

- PHP 8.2+
- Composer
- MySQL 8.0+
- Node.js & npm (optional, for frontend assets)

---

## 🚀 Local Setup

### 1. Clone & Install

```bash
cd task-manager_backend
composer install
```

### 2. Environment Configuration

```bash
cp .env.example .env
php artisan key:generate
php artisan jwt:secret
```

### 3. Configure .env File

Edit `.env` with your database credentials:

```env
# ============================================
# APP
# ============================================
APP_NAME="Task Manager"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

# ============================================
# DATABASE
# ============================================
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=task_manager
DB_USERNAME=root
DB_PASSWORD=

# ============================================
# CACHE & SESSION
# ============================================
CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync

# ============================================
# JWT
# ============================================
JWT_SECRET=your_generated_secret_here
JWT_ALGORITHM=HS256
JWT_TTL=60
```

### 4. Database Setup

```bash
php artisan migrate:fresh --seed
```

This will create tables and seed 10 sample tasks.

### 5. Start Development Server

```bash
php artisan serve
```

Server runs at: `http://localhost:8000`

---

## 🗄️ Database Schema

### Users Table

```sql
id (primary)
name (string)
email (unique)
password (hashed)
created_at, updated_at
```

### Tasks Table

```sql
id (primary)
user_id (foreign → users)
title (string)
description (nullable text)
status (enum: pending, in-progress, done)
priority (enum: low, medium, high)
due_date (nullable date)
created_at, updated_at
```

### File Attachments Table

```sql
id (primary)
task_id (foreign → tasks)
filename (string)
original_filename (string)
mime_type (string)
size (integer)
path (string)
created_at, updated_at
```

---

## 🔌 API Reference

### Base URL

```
http://localhost:8000/api
```

### Authentication Header

```
Authorization: Bearer {token}
```

---

## 🔐 Authentication Endpoints

### Register

**POST** `/auth/register`

**Request:**

```json
{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123"
}
```

**Response (201):**

```json
{
    "message": "Registration successful",
    "data": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
    }
}
```

---

### Login

**POST** `/auth/login`

**Request:**

```json
{
    "email": "john@example.com",
    "password": "password123"
}
```

**Response (200):**

```json
{
    "message": "Login successful",
    "data": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "token": "eyJ0eXAiOiJKV1QiLCJhbGc..."
    }
}
```

---

### Get Current User

**GET** `/auth/me` (Protected)

**Response (200):**

```json
{
    "message": "Current user retrieved",
    "data": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com"
    }
}
```

---

### Logout

**POST** `/auth/logout` (Protected)

**Response (200):**

```json
{
    "message": "Logged out successfully"
}
```

---

## ✅ Task Endpoints

### Get All Tasks (Protected)

**GET** `/tasks?status=pending&priority=high&per_page=15&page=1`

**Query Parameters:**

- `status` - Filter by status (`pending`, `in-progress`, `done`)
- `priority` - Filter by priority (`low`, `medium`, `high`)
- `per_page` - Items per page (default: 15)
- `page` - Page number (default: 1)

**Response (200):**

```json
{
    "message": "Tasks retrieved successfully",
    "data": [
        {
            "id": 1,
            "title": "Complete project",
            "description": "Finish the task manager app",
            "status": "in-progress",
            "priority": "high",
            "due_date": "2026-04-30",
            "created_at": "2026-04-12T10:30:00Z",
            "updated_at": "2026-04-12T10:30:00Z"
        }
    ],
    "pagination": {
        "total": 10,
        "per_page": 15,
        "current_page": 1,
        "last_page": 1
    }
}
```

---

### Get Single Task (Protected)

**GET** `/tasks/{id}`

**Response (200):**

```json
{
    "message": "Task retrieved successfully",
    "data": {
        "id": 1,
        "title": "Complete project",
        "description": "Finish the task manager app",
        "status": "in-progress",
        "priority": "high",
        "due_date": "2026-04-30",
        "attachments": [
            {
                "id": 1,
                "filename": "task_1_abc123.pdf",
                "original_filename": "document.pdf",
                "mime_type": "application/pdf",
                "size": 1048576,
                "path": "tasks/task_1_abc123.pdf"
            }
        ]
    }
}
```

---

### Create Task (Protected)

**POST** `/tasks`

**Request:**

```json
{
    "title": "New task",
    "description": "Task description",
    "status": "pending",
    "priority": "medium",
    "due_date": "2026-04-30"
}
```

**Response (201):**

```json
{
    "message": "Task created successfully",
    "data": {
        "id": 11,
        "title": "New task",
        "description": "Task description",
        "status": "pending",
        "priority": "medium",
        "due_date": "2026-04-30",
        "created_at": "2026-04-12T10:40:00Z"
    }
}
```

---

### Update Task (Protected)

**PUT** `/tasks/{id}`

**Request:**

```json
{
    "title": "Updated title",
    "status": "in-progress",
    "priority": "high"
}
```

**Response (200):**

```json
{
    "message": "Task updated successfully",
    "data": {
        "id": 1,
        "title": "Updated title",
        "status": "in-progress",
        "priority": "high"
    }
}
```

---

### Delete Task (Protected)

**DELETE** `/tasks/{id}`

**Response (200):**

```json
{
    "message": "Task deleted successfully"
}
```

---

### Upload File to Task (Protected)

**POST** `/tasks/{id}/attach-file`

**Form Data:**

- `file` - File to upload (max 2MB, types: pdf, jpg, jpeg, png, gif)

**Response (201):**

```json
{
    "message": "File attached successfully",
    "data": {
        "id": 1,
        "task_id": 1,
        "filename": "task_1_abc123.pdf",
        "original_filename": "document.pdf",
        "mime_type": "application/pdf",
        "size": 1048576,
        "path": "tasks/task_1_abc123.pdf"
    }
}
```

---

## ⚠️ Error Responses

### Validation Error (422)

```json
{
    "message": "Validation failed",
    "errors": {
        "email": ["The email field is required."],
        "password": ["The password must be at least 8 characters."]
    }
}
```

### Unauthorized (401)

```json
{
    "message": "Unauthorized",
    "errors": {
        "general": "Invalid credentials"
    }
}
```

### Not Found (404)

```json
{
    "message": "Task not found",
    "errors": {
        "task": "The requested task does not exist"
    }
}
```

### Server Error (500)

```json
{
    "message": "Internal server error",
    "errors": {
        "general": "Something went wrong"
    }
}
```

---

## 🧪 Testing Endpoints

### Using cURL

**Register:**

```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

**Login:**

```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

**Get Tasks:**

```bash
curl -X GET http://localhost:8000/api/tasks \
  -H "Authorization: Bearer {your_token_here}"
```

**Create Task:**

```bash
curl -X POST http://localhost:8000/api/tasks \
  -H "Authorization: Bearer {your_token_here}" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "My new task",
    "description": "Task description",
    "status": "pending",
    "priority": "high",
    "due_date": "2026-04-30"
  }'
```

**Upload File:**

```bash
curl -X POST http://localhost:8000/api/tasks/1/attach-file \
  -H "Authorization: Bearer {your_token_here}" \
  -F "file=@/path/to/file.pdf"
```

---

## 📁 Project Structure

```
app/
├── Http/
│   ├── Controllers/
│   │   ├── AuthController.php
│   │   └── TaskController.php
│   ├── Requests/
│   │   ├── LoginRequest.php
│   │   ├── RegisterRequest.php
│   │   └── TaskRequest.php
│   └── Middleware/
│       └── HandleJWTAuthentication.php
├── Models/
│   ├── User.php
│   ├── Task.php
│   └── FileAttachment.php
└── Providers/
    └── AppServiceProvider.php

database/
├── migrations/
│   ├── 2024_01_01_create_users_table.php
│   ├── 2024_04_11_create_tasks_table.php
│   └── 2024_04_11_create_file_attachments_table.php
└── seeders/
    ├── DatabaseSeeder.php
    └── TaskSeeder.php

routes/
└── api.php

config/
└── jwt.php
```

---

## 🔒 Security

- ✅ JWT token expires after 60 minutes
- ✅ Password hashed with bcrypt
- ✅ File uploads validated (type & size)
- ✅ CORS enabled for Flutter app
- ✅ SQL injection protection (Eloquent ORM)

---

## 📝 License

This project is open source and available under the MIT license.

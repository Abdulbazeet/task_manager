# Task Manager - Push to GitHub

This guide will help you push the Task Manager project to your GitHub repository.

## Prerequisites

- Git installed on your machine
- GitHub account with the repo created: https://github.com/Abdulbazeet/task_manager

## Setup Steps

### 1. Initialize Git (if not already done)

```bash
cd "/home/olatunji/Flutter Apps/tasks"
git init
```

### 2. Add Remote Repository

```bash
git remote add origin https://github.com/Abdulbazeet/task_manager.git
```

### 3. Configure Git (if first time)

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 4. Create .gitignore Files (Already Done ✅)

The following have been configured:

- **Root .gitignore** (`/home/olatunji/Flutter Apps/tasks/.gitignore`)
  - Covers both backend and Flutter
  - Ignores `.env` files and environment secrets
- **Backend .gitignore** (`task-manager_backend/.gitignore`)
  - Laravel-specific files and vendor directory
  - Environment files (.env, .env.backup, .env.production)
  - Cache and build artifacts

## Critical Security: .env Files

The following will be IGNORED (not uploaded):

```
✅ task-manager_backend/.env
✅ task-manager_backend/.env.backup
✅ task-manager_backend/.env.production
✅ .env
✅ .env.local
```

### 5. Add Files to Git

```bash
cd "/home/olatunji/Flutter Apps/tasks"
git add .
```

### 6. Verify What Will Be Pushed

```bash
git status
```

**Important**: Make sure `.env` files are NOT listed as changes to commit. They should appear as ignored.

### 7. Create Initial Commit

```bash
git commit -m "Initial commit: Complete task manager app with Flutter frontend and Laravel backend"
```

### 8. Push to GitHub

```bash
git branch -M main
git push -u origin main
```

## After First Push

For subsequent commits:

```bash
git add .
git commit -m "Your commit message"
git push
```

## What's Being Tracked

✅ **Backend (Laravel)**

- Source code (`app/`, `routes/`, `database/`, etc.)
- Config files (except .env)
- Migrations and seeders
- Controllers, Models, Requests

✅ **Flutter App**

- All dart files
- Assets and SVGs
- Configuration
- pubspec.yaml (but not pubspec.lock)
- Generated files needed for build

❌ **NOT Being Tracked (Ignored)**

- .env files (sensitive data)
- vendor/ (composer dependencies)
- node_modules/ (npm dependencies)
- build/ artifacts
- .dart_tool/ (Flutter build artifacts)
- iOS/Android build outputs

## .env Files Setup

**For collaborators**, they'll need to create their own .env file:

### Backend (.env)

```
Create `task-manager_backend/.env` with:
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=task_manager
DB_USERNAME=root
DB_PASSWORD=your_password
JWT_SECRET=your_jwt_secret
APP_KEY=your_app_key
```

Provide `.env.example` in the repo as a template.

## Troubleshooting

### .env file accidentally pushed?

```bash
git rm --cached task-manager_backend/.env
git commit -m "Remove .env from tracking"
git push
```

### Need to undo last commit?

```bash
git reset --soft HEAD~1
git reset HEAD .env
git commit -m "Fixed: exclude .env"
git push --force-with-lease
```

### Large files rejected?

Use Git LFS for large files if needed:

```bash
git lfs install
git lfs track "*.zip"
```

---

**Your project is ready to push!** 🚀

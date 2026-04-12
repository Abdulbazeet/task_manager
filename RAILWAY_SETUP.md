# Railway Deployment - Flutter Configuration

Your backend is now live on Railway! ✅

## Step 1: Get Your Railway URL

1. Go to [railway.app](https://railway.app)
2. Click on your **task-manager** project
3. Click the **task-manager_backend** service
4. Look for **"Public URL"** or **"Domain"** section
5. Copy the URL (example: `https://xxx.railway.app`)

## Step 2: Update Flutter Base URL

Edit this file: [lib/services/repository/task_repository.dart](lib/services/repository/task_repository.dart)

**Find this line (line 10):**
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

**Replace it with:**
```dart
static const String baseUrl = 'https://YOUR-RAILWAY-URL/api';
```

**Example:**
```dart
static const String baseUrl = 'https://task-manager-xyz.railway.app/api';
```

## Step 3: Rebuild Flutter

```bash
cd "/home/olatunji/Flutter Apps/tasks"
flutter pub get
flutter clean
flutter run
```

## Step 4: Test API Connectivity

1. **Test Login** - Try signing in with your credentials
2. **Check Network Logs** - You should see requests to your Railway URL (not localhost)
3. **Create a Task** - Create a new task, should sync with live database
4. **Upload File** - Try attaching a file to a task

## Troubleshooting

**"Connection refused" error?**
- Verify the URL is correct (no trailing slash)
- Check Railway dashboard - service should show "Running"
- Wait 60 seconds for Railway to stabilize

**Tasks not loading?**
- Check Railway environment variables are set correctly
- Verify JWT_SECRET is configured in Railway
- Check Railway logs for PHP errors

**File upload not working?**
- Ensure `/api/tasks/{id}/attach-file` endpoint exists on backend
- Check file size is under 2MB

---

**Need help?** Check the deployment logs in Railway dashboard.

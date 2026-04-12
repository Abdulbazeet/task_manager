import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tasks/core/token_manager.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/models/file_attachment.dart';
import '../../config/exception.dart';

class TaskRepository {
  static const String baseUrl =
      'https://taskmanager-production-dee.up.railway.app/api';

  // Get all tasks
  Future<List<Task>> getTasks({
    String? status,
    String? priority,
    int perPage = 15,
    int page = 1,
  }) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) throw ApiException('No token found');

      final queryParams = {
        'per_page': perPage.toString(),
        'page': page.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (priority != null) queryParams['priority'] = priority;

      final response = await http.get(
        Uri.parse('$baseUrl/tasks').replace(queryParameters: queryParams),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final taskList = (data['data'] as List)
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList();
        return taskList;
      } else {
        throw ApiException(
          'Failed to get tasks - Status: ${response.statusCode}, Body: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Get single task
  Future<Task> getTask(int id) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) throw ApiException('No token found');

      final response = await http.get(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Task.fromJson(data['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw ApiException('Task not found', statusCode: 404);
      } else {
        throw ApiException(
          'Failed to get task',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Create task
  Future<Task> createTask({
    required String title,
    String? description,
    required String status,
    required String priority,
    DateTime? dueDate,
  }) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) throw ApiException('No token found');

      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: _getHeaders(token),
        body: jsonEncode({
          'title': title,
          'description': description,
          'status': status,
          'priority': priority,
          'due_date': dueDate?.toIso8601String().split('T').first,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Task.fromJson(data['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(
          data['message'] ?? 'Validation failed',
          statusCode: 422,
        );
      } else {
        throw ApiException(
          'Failed to create task',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Update task
  Future<Task> updateTask(
    int id, {
    required String title,
    String? description,
    required String status,
    required String priority,
    DateTime? dueDate,
  }) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) throw ApiException('No token found');

      final response = await http.put(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: _getHeaders(token),
        body: jsonEncode({
          'title': title,
          'description': description,
          'status': status,
          'priority': priority,
          'due_date': dueDate?.toIso8601String().split('T').first,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return Task.fromJson(data['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw ApiException('Task not found', statusCode: 404);
      } else {
        throw ApiException(
          'Failed to update task',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Delete task
  Future<void> deleteTask(int id) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) throw ApiException('No token found');

      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: _getHeaders(token),
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 404) {
          throw ApiException('Task not found', statusCode: 404);
        } else {
          throw ApiException(
            'Failed to delete task',
            statusCode: response.statusCode,
          );
        }
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Attach file to task
  Future<FileAttachment> attachFile(int taskId, File file) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) throw ApiException('No token found');

      // Check file size (max 2 MB)
      final fileSizeInMB = file.lengthSync() / (1024 * 1024);
      if (fileSizeInMB > 2) {
        throw ApiException('File size must not exceed 2 MB', statusCode: 422);
      }

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/tasks/$taskId/attach-file'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Send request
      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return FileAttachment.fromJson(data['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(
          data['message'] ?? 'Validation failed',
          statusCode: 422,
        );
      } else if (response.statusCode == 404) {
        throw ApiException('Task not found', statusCode: 404);
      } else {
        throw ApiException(
          'Failed to attach file',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}

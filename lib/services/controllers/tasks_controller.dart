import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/models/file_attachment.dart';
import 'package:tasks/services/repository/task_repository.dart';

class TasksController extends AsyncNotifier<List<Task>> {
  late TaskRepository _taskRepository;

  @override
  Future<List<Task>> build() async {
    _taskRepository = TaskRepository();
    return await _taskRepository.getTasks();
  }

  Future<void> fetchTasks({
    String? status,
    String? priority,
    int perPage = 15,
    int page = 1,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _taskRepository.getTasks(
        status: status,
        priority: priority,
        perPage: perPage,
        page: page,
      );
    });
  }

  Future<Task> createTask({
    required String title,
    String? description,
    required String status,
    required String priority,
    DateTime? dueDate,
  }) async {
    final task = await _taskRepository.createTask(
      title: title,
      description: description,
      status: status,
      priority: priority,
      dueDate: dueDate,
    );

    state.whenData((tasks) {
      state = AsyncValue.data([...tasks, task]);
    });

    return task;
  }

  Future<Task> updateTask(
    int id, {
    required String title,
    String? description,
    required String status,
    required String priority,
    DateTime? dueDate,
  }) async {
    final updatedTask = await _taskRepository.updateTask(
      id,
      title: title,
      description: description,
      status: status,
      priority: priority,
      dueDate: dueDate,
    );

    state.whenData((tasks) {
      final index = tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        tasks[index] = updatedTask;
        state = AsyncValue.data([...tasks]);
      }
    });

    return updatedTask;
  }

  Future<void> deleteTask(int id) async {
    await _taskRepository.deleteTask(id);

    state.whenData((tasks) {
      state = AsyncValue.data(tasks.where((t) => t.id != id).toList());
    });
  }

  Future<Task> getTask(int id) async {
    return await _taskRepository.getTask(id);
  }

  Future<FileAttachment> uploadFile(int taskId, File file) async {
    return await _taskRepository.attachFile(taskId, file);
  }
}

final tasksProvider = AsyncNotifierProvider<TasksController, List<Task>>(
  () => TasksController(),
);

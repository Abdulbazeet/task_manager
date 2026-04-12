import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tasks/models/task.dart';
import 'package:tasks/services/controllers/tasks_controller.dart';
import 'package:tasks/config/utils.dart';

class EditScreen extends ConsumerStatefulWidget {
  final int taskId;

  const EditScreen({super.key, required this.taskId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditScreenState();
}

class _EditScreenState extends ConsumerState<EditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  int selectedIndex = 1;
  String selectedPriority = 'medium';
  int selectedStatusIndex = 0;
  String selectedStatus = 'pending';
  DateTime? chosenDate;
  File? selectedFile;
  String? selectedFileName;
  bool isLoading = false;
  Task? currentTask;

  void _loadTask() {
    final tasksAsyncValue = ref.read(tasksProvider);
    final tasks = tasksAsyncValue.value;

    if (tasks != null && tasks.isNotEmpty) {
      currentTask = tasks.firstWhere(
        (t) => t.id == widget.taskId,
        orElse: () => tasks.first,
      );
      _populateFields();
    }
  }

  void _populateFields() {
    if (currentTask != null) {
      _titleController.text = currentTask!.title;
      _descriptionController.text = currentTask!.description ?? '';
      selectedPriority = currentTask!.priority;
      selectedStatus = currentTask!.status;
      chosenDate = currentTask!.dueDate;

      final priorityValues = ['low', 'medium', 'high'];
      selectedIndex = priorityValues.indexOf(selectedPriority);

      final statusValues = ['pending', 'in-progress', 'done'];
      selectedStatusIndex = statusValues.indexOf(selectedStatus);
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadTask();
  }

  Future<void> _updateTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Update task first
      await ref
          .read(tasksProvider.notifier)
          .updateTask(
            widget.taskId,
            title: _titleController.text,
            description: _descriptionController.text,
            status: selectedStatus,
            priority: selectedPriority,
            dueDate: chosenDate,
          );

      // Upload file if selected
      if (selectedFile != null) {
        try {
          await ref
              .read(tasksProvider.notifier)
              .uploadFile(widget.taskId, selectedFile!);

          if (mounted) {
            Utils.showSnackBar(
              context,
              message: 'File uploaded successfully!',
              isSuccess: true,
            );
          }
        } catch (e) {
          if (mounted) {
            Utils.showSnackBar(
              context,
              message: 'Task updated but file upload failed: $e',
              isSuccess: false,
            );
          }
        }
      }

      if (mounted) {
        Utils.showSnackBar(
          context,
          message: 'Task updated successfully!',
          isSuccess: true,
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        Utils.showSnackBar(
          context,
          message: 'Error: ${e.toString()}',
          isSuccess: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Task',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: .bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                'TITLE',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: .bold,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 5),
              TextField(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
                controller: _titleController,
                decoration: InputDecoration(
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1A1A20)
                      : Colors.white,
                  filled: true,
                  hintText: 'Enter task title',
                  hintStyle: Theme.of(context).textTheme.bodySmall,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 0, color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 0, color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 0, color: Colors.transparent),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'DESCRIPTION',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: .bold,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 5),
              TextField(
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
                controller: _descriptionController,
                minLines: 4,
                maxLines: null,
                decoration: InputDecoration(
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1A1A20)
                      : Colors.white,
                  filled: true,
                  hintText: 'Add description',
                  hintStyle: Theme.of(context).textTheme.bodySmall,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 0, color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 0, color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 0, color: Colors.transparent),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'PRIORITY',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: .bold,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: List.generate(3, (index) {
                  final List<String> priorityLabels = ['Low', 'Medium', 'High'];
                  final List<String> priorityValues = ['low', 'medium', 'high'];
                  final onSelected = selectedIndex == index;
                  final priorityColor = Utils.getPriorityColor(
                    priorityValues[index],
                  );
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        selectedPriority = priorityValues[index];
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: onSelected
                            ? priorityColor.withValues(alpha: 0.3)
                            : (Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF1A1A20)
                                  : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: onSelected
                              ? priorityColor
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        priorityLabels[index],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: onSelected ? priorityColor : null,
                          fontWeight: onSelected ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 30),
              Text(
                'STATUS',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: .bold,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: List.generate(3, (index) {
                  final List<String> statusLabels = [
                    'Pending',
                    'In Progress',
                    'Done',
                  ];
                  final List<String> statusValues = [
                    'pending',
                    'in-progress',
                    'done',
                  ];
                  final onSelected = selectedStatusIndex == index;
                  final statusColor = statusValues[index] == 'done'
                      ? Colors.green
                      : statusValues[index] == 'in-progress'
                      ? Colors.orange
                      : Colors.blue;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedStatusIndex = index;
                        selectedStatus = statusValues[index];
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: onSelected
                            ? statusColor.withValues(alpha: 0.3)
                            : (Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF1A1A20)
                                  : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: onSelected ? statusColor : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        statusLabels[index],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: onSelected ? statusColor : null,
                          fontWeight: onSelected ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 30),
              Text(
                'DUE DATE',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: .bold,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  final date = showDatePicker(
                    context: context,
                    initialDate: chosenDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  date.then((value) {
                    if (value != null) {
                      setState(() {
                        chosenDate = value;
                      });
                    }
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1A1A20)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      chosenDate != null
                          ? Text(
                              'Due: ${DateFormat('MMM dd, yyyy').format(chosenDate!)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                            )
                          : Text(
                              'Select due date',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                      Icon(
                        Icons.calendar_month_outlined,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    'ATTACHMENTS',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: .bold,
                      fontSize: 12,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1A1A20)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'OPTIONAL',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              GestureDetector(
                onTap: () {
                  Utils.pickFile(
                    context: context,
                    onFileSelected: (file) {
                      setState(() {
                        selectedFile = File(file.path ?? '');
                        selectedFileName = file.name;
                      });
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1A1A20)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: .center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.file_copy,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        selectedFileName ?? 'Attach file',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontWeight: .w500,
                        ),
                      ),
                      Text(
                        selectedFileName != null
                            ? 'Click to change file'
                            : 'File should not be more than 10 MB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed:
                      isLoading ||
                          _titleController.text.isEmpty ||
                          _descriptionController.text.isEmpty ||
                          chosenDate == null
                      ? null
                      : () => _updateTask(),
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Update Task',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

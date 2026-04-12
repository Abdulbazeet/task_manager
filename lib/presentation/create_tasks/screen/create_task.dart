import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tasks/services/controllers/tasks_controller.dart';
import 'package:tasks/config/utils.dart';

class CreateTask extends ConsumerStatefulWidget {
  const CreateTask({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CreateTaskState();
}

class _CreateTaskState extends ConsumerState<CreateTask> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int selectedIndex = 1;
  String selectedPriority = 'medium';
  DateTime? chosenDate;
  File? selectedFile;
  String? selectedFileName;
  bool isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // This is to create task
  Future<void> _createTask() async {
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
      // Create task first
      final task = await ref
          .read(tasksProvider.notifier)
          .createTask(
            title: _titleController.text,
            description: _descriptionController.text,
            status: 'pending',
            priority: selectedPriority,
            dueDate: chosenDate,
          );

      // Upload file if selected
      if (selectedFile != null) {
        try {
          await ref
              .read(tasksProvider.notifier)
              .uploadFile(task.id, selectedFile!);

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
              message: 'Task created but file upload failed: $e',
              isSuccess: false,
            );
          }
        }
      }

      if (mounted) {
        Utils.showSnackBar(
          context,
          message: 'Task created successfully!',
          isSuccess: true,
        );
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go('/home');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        Utils.showSnackBar(
          context,
          message: 'Failed to create task: $e',
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Task',
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.black),

                controller: _titleController,

                decoration: InputDecoration(
                  fillColor: Colors.white,
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.black),

                controller: _descriptionController,
                minLines: 4,
                maxLines: null,

                decoration: InputDecoration(
                  fillColor: Colors.white,
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
                            : Colors.white,
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
                    initialDate: DateTime.now(),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      chosenDate != null
                          ? Text(
                              'Due: ${DateFormat('MMM dd, yyyy').format(chosenDate!)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.black),
                            )
                          : Text(
                              'Select due date',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                      Icon(
                        Icons.calendar_month_outlined,
                        color: Colors.black54,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'OPTIONAL',
                      style: TextStyle(fontSize: 10, color: Colors.black87),
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
                    color: Colors.white,
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
                        textAlign: .center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: .w500,
                        ),
                      ),
                      Text(
                        selectedFileName != null
                            ? 'Click to change file'
                            : 'File should not be more than 10 MB',
                        textAlign: .center,
                        style: TextStyle(fontSize: 12, color: Colors.black54),
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
                      : () => _createTask(),
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
                          'Create Task',
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

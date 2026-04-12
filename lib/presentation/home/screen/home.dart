import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasks/services/controllers/tasks_controller.dart';
import 'package:tasks/services/controllers/auth_controller.dart';
import 'package:tasks/widget/task_list.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(authProvider.notifier).logout().then((_) {
                context.go('/');
              });
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tasksProvider.notifier).fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final tasksState = ref.watch(tasksProvider);

    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('My Tasks')),
        body: Center(child: Text('Auth Error: $error')),
      ),
      data: (user) {
        if (user == null) {
          Future.microtask(() => context.go('/'));
          return const Scaffold(body: SizedBox());
        }

        return tasksState.when(
          data: (allTasks) {
            final pendingTasks = allTasks
                .where((t) => t.status == 'pending')
                .toList();
            final inProgressTasks = allTasks
                .where((t) => t.status == 'in-progress')
                .toList();
            final doneTasks = allTasks
                .where((t) => t.status == 'done')
                .toList();

            return DefaultTabController(
              length: 4,
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    'My Tasks',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  actions: [
                    PopupMenuButton(
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          child: const Text('Logout'),
                          onTap: () {
                            _showLogoutDialog(context);
                          },
                        ),
                      ],
                    ),
                  ],
                  bottom: TabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(text: 'All (${allTasks.length})'),
                      Tab(text: 'Pending (${pendingTasks.length})'),
                      Tab(text: 'In Progress (${inProgressTasks.length})'),
                      Tab(text: 'Done (${doneTasks.length})'),
                    ],
                  ),
                ),
                body: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(tasksProvider.notifier).fetchTasks(),
                  child: TabBarView(
                    children: [
                      TaskList(tasks: allTasks),
                      TaskList(tasks: pendingTasks),
                      TaskList(tasks: inProgressTasks),
                      TaskList(tasks: doneTasks),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    context.push('/create-task');
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            );
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: const Text('My Tasks')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(tasksProvider.notifier).fetchTasks();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

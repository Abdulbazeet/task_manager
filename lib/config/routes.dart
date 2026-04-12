import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tasks/services/controllers/auth_controller.dart';
import 'package:tasks/presentation/create_tasks/screen/create_task.dart';
import 'package:tasks/presentation/edit/screen/edit_screen.dart';
import 'package:tasks/presentation/home/screen/home.dart';
import 'package:tasks/presentation/sign_in/screen/sign_in.dart';
import 'package:tasks/presentation/sign_up/screen/sign_up.dart';

class AppRoutes {
  static GoRouter router(Ref ref) => GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SignIn()),
      GoRoute(builder: (context, state) => const SignUp(), path: '/sign-up'),
      GoRoute(path: '/home', builder: (context, state) => const Home()),
      GoRoute(
        path: '/create-task',
        builder: (context, state) => const CreateTask(),
      ),
      GoRoute(
        path: '/edit-task/:id',
        builder: (context, state) {
          final taskId = int.parse(state.pathParameters['id'] ?? '0');
          return EditScreen(taskId: taskId);
        },
      ),
    ],
    redirect: (context, state) {
      final authState = ref.watch(authProvider);

      return authState.when(
        data: (user) {
          if (user != null) {
            if (state.matchedLocation == '/' ||
                state.matchedLocation == '/sign-up') {
              return '/home';
            }
            return null;
          } else {
           
            if (state.matchedLocation.startsWith('/home') ||
                state.matchedLocation.startsWith('/create-task') ||
                state.matchedLocation.startsWith('/edit-task')) {
              return '/';
            }
            return null;
          }
        },
        error: (e, st) {
        
          return '/';
        },
        loading: () {
         
          return null;
        },
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  ref.watch(authProvider); 
  return AppRoutes.router(ref);
});

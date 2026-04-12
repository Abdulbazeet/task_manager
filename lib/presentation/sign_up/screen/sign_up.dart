import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tasks/services/controllers/auth_controller.dart';
import 'package:tasks/widget/text_field.dart';

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpState();
}

class _SignUpState extends ConsumerState<SignUp> {
  bool _firstHidden = true;
  bool _secondHidden = true;
  bool _passwordsMatch = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    setState(() => _errorMessage = null);

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .register(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
          );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(
        () => _errorMessage = e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/svgs/logo.svg',
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Task Flow',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create your account',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Get started managing your tasks today',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 30),
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red, width: 0.5),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],

                      textField(
                        context: context,
                        label: 'NAME',
                        hint: 'Enter your name',
                        icon: Icons.person,
                        obscureText: false,
                        controller: _nameController,
                      ),
                      const SizedBox(height: 10),
                      textField(
                        context: context,
                        label: 'EMAIL',
                        hint: 'Enter your email',
                        icon: Icons.email,
                        obscureText: false,
                        controller: _emailController,
                      ),
                      const SizedBox(height: 10),
                      textField(
                        context: context,
                        label: 'PASSWORD',
                        hint: '**********',
                        icon: Icons.lock,
                        obscureText: _firstHidden,
                        controller: _passwordController,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _firstHidden = !_firstHidden;
                            });
                          },
                          icon: Icon(
                            _firstHidden
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      textField(
                        context: context,
                        label: 'CONFIRM PASSWORD',
                        hint: '**********',
                        icon: Icons.lock,
                        obscureText: _secondHidden,
                        controller: _confirmPasswordController,
                        onChanged: (value) {
                          setState(() {
                            _passwordsMatch =
                                _passwordController.text ==
                                _confirmPasswordController.text;
                          });
                        },
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _secondHidden = !_secondHidden;
                            });
                          },
                          icon: Icon(
                            _secondHidden
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                      if (_confirmPasswordController.text.isNotEmpty &&
                          !_passwordsMatch)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_rounded,
                                color: Colors.orange.shade700,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Passwords do not match',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed:
                            (authState.isLoading ||
                                (_confirmPasswordController.text.isNotEmpty &&
                                    !_passwordsMatch))
                            ? null
                            : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Create Account',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                      ),
                      const SizedBox(height: 30),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 30),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: Theme.of(context).textTheme.bodySmall,
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.go('/');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

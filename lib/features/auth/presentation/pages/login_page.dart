import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_translator_test/core/route/app_routes.dart';
import 'package:smart_translator_test/core/util/responsive.dart';
import 'package:smart_translator_test/core/widgets/server_status_indicator.dart';

import '../controller/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_key.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [ServerStatusIndicator()]),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final bool isLoading = state is AuthLoading;
            return Center(
              child: SingleChildScrollView(
                padding: context.screenPadding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.isTablet ? 450 : double.infinity,
                  ),
                  child: Form(
                    key: _key,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          size: context.sp(64, min: 48, max: 80),
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(height: context.hp(2)),
                        Text(
                          "Welcome Back!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: context.sp(28, min: 22, max: 32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: context.hp(1)),
                        Text(
                          "Sign in to continue exploring languages",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: context.sp(15, min: 13, max: 18),
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: context.hp(4)),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            hintText: "Enter your email",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                context.defaultRadius,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: context.hp(2)),
                        TextFormField(
                          obscureText: true,
                          controller: _passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "Enter your password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: const Icon(
                              Icons.visibility_off_outlined,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                context.defaultRadius,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: context.hp(1)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontSize: context.sp(13, min: 11, max: 15),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: context.hp(2.5)),
                        ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: context.hp(1.8).clamp(14.0, 20.0),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                context.defaultRadius,
                              ),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: context.sp(20),
                                  width: context.sp(20),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: context.sp(16, min: 14, max: 18),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        SizedBox(height: context.hp(2.5)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                fontSize: context.sp(14, min: 12, max: 16),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.go(AppRoutes.register);
                              },
                              child: Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: context.sp(14, min: 12, max: 16),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

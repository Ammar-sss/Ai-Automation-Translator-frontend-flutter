import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_translator/core/router/route_name.dart';
import 'package:smart_translator/core/utils/validators.dart';

import '../controllers/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final bool _obscurePassword = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitLogin() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    context.read<AuthBloc>().add(
      AuthLoginRequested(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text("Email"),
                  TextFormField(
                    validator: (value) => Validators.email(value),
                    controller: _emailController,
                  ),
                  Text("Password"),
                  TextFormField(
                    validator: (value) => Validators.loginPassword(value),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                  ),
                  ElevatedButton(
                    onPressed: () => _submitLogin(),
                    child: Text("login"),
                  ),
                  ElevatedButton(
                    onPressed: () => context.push(RouteName.register),
                    child: Text("register"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

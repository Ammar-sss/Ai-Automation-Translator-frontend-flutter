import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator/features/auth/presentation/controllers/auth_bloc.dart';

import '../../../../core/utils/validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final bool _obscurePassword = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitRegister() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
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
            } else if (state is AuthRegistered) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Registered Successfully! please login in"),
                ),
              );
              Navigator.pop(context);
            }
          },
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text("Username"),
                  TextFormField(
                    validator: (value) => Validators.username(value),
                    controller: _usernameController,
                  ),
                  Text("Email"),
                  TextFormField(
                    validator: (value) => Validators.email(value),
                    controller: _emailController,
                  ),
                  Text("Password"),
                  TextFormField(
                    validator: (value) => Validators.strongPassword(value),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                  ),
                  ElevatedButton(
                    child: Text("register"),
                    onPressed: () => _submitRegister(),
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

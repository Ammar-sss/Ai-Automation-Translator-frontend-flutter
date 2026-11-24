import 'package:material_ui/material_ui.dart';
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
  bool _obscurePassword = true;

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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(actions: [const ServerStatusIndicator()]),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(state.message),
                  backgroundColor: scheme.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                    maxWidth: context.isTablet ? 440 : double.infinity,
                  ),
                  child: Form(
                    key: _key,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withValues(
                                alpha: 0.7,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.translate_rounded,
                              size: context.sp(48, min: 36, max: 60),
                              color: scheme.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: context.hp(2.5)),
                        Text(
                          "Welcome Back!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: context.sp(28, min: 22, max: 32),
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: context.hp(1)),
                        Text(
                          "Sign in to continue exploring languages",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: context.sp(15, min: 13, max: 17),
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: context.hp(4)),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Email",
                            hintText: "Enter your email",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        SizedBox(height: context.hp(2)),
                        TextFormField(
                          obscureText: _obscurePassword,
                          controller: _passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "Enter your password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        SizedBox(height: context.hp(0.8)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontSize: context.sp(13, min: 11, max: 15),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: context.hp(2.5)),
                        FilledButton(
                          onPressed: isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: context.hp(1.8).clamp(14.0, 20.0),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: context.sp(20),
                                  width: context.sp(20),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: scheme.onPrimary,
                                  ),
                                )
                              : Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: context.sp(16, min: 14, max: 18),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                        SizedBox(height: context.hp(2.5)),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                fontSize: context.sp(14, min: 12, max: 16),
                                color: scheme.onSurfaceVariant,
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
                                  fontWeight: FontWeight.w700,
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

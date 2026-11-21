import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_translator_test/core/route/app_routes.dart';
import 'package:smart_translator_test/core/util/responsive.dart';
import 'package:smart_translator_test/features/auth/presentation/controller/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _key = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_key.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          username: _nameController.text.trim(),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            size: context.sp(22, min: 20, max: 26),
          ),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
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
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withValues(
                                alpha: 0.7,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_add_alt_1_rounded,
                              size: context.sp(44, min: 32, max: 56),
                              color: scheme.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: context.hp(2)),
                        Text(
                          "Create Account",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: context.sp(28, min: 22, max: 32),
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: context.hp(1)),
                        Text(
                          "Sign up to get started with Smart Translator",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: context.sp(15, min: 13, max: 17),
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: context.hp(3)),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Full Name",
                            hintText: "Enter your full name",
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        SizedBox(height: context.hp(2)),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!val.contains('@')) {
                              return 'Please enter a valid email address';
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
                          textInputAction: TextInputAction.next,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please create a password';
                            }
                            if (val.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "Create a password",
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
                        SizedBox(height: context.hp(2)),
                        TextFormField(
                          obscureText: _obscureConfirmPassword,
                          controller: _confirmPasswordController,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (val != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            hintText: "Confirm your password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        SizedBox(height: context.hp(3)),
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
                                  "Register",
                                  style: TextStyle(
                                    fontSize: context.sp(16, min: 14, max: 18),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                        SizedBox(height: context.hp(2)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: TextStyle(
                                fontSize: context.sp(14, min: 12, max: 16),
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.go(AppRoutes.login);
                              },
                              child: Text(
                                "Login",
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

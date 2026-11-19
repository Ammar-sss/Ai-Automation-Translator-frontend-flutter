import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_translator_test/core/route/app_routes.dart';
import 'package:smart_translator_test/core/util/responsive.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: context.sp(22, min: 20, max: 26)),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: context.screenPadding,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.isTablet ? 450 : double.infinity,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Create Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.sp(28, min: 22, max: 32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: context.hp(1)),
                  Text(
                    "Sign up to get started with Smart Translator",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: context.sp(15, min: 13, max: 18),
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: context.hp(3)),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      hintText: "Enter your full name",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.defaultRadius,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.hp(2)),
                  TextField(
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
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Create a password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: const Icon(Icons.visibility_off_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.defaultRadius,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.hp(2)),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      hintText: "Confirm your password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: const Icon(Icons.visibility_off_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.defaultRadius,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: context.hp(3)),
                  ElevatedButton(
                    onPressed: () {
                      // Pure design: navigation placeholder or no logic action
                    },
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
                    child: Text(
                      "Register",
                      style: TextStyle(
                        fontSize: context.sp(16, min: 14, max: 18),
                        fontWeight: FontWeight.bold,
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
      ),
    );
  }
}

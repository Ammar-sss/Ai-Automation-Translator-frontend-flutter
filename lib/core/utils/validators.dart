import '../config/app_constants.dart';

/// Client-side validation that mirrors the backend rules:
/// `@Email` / `@Size` on the DTOs, plus the service's
/// `validatePasswordStrength()`.
abstract final class Validators {
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _uppercase = RegExp(r'[A-Z]');
  static final RegExp _lowercase = RegExp(r'[a-z]');
  static final RegExp _digit = RegExp(r'\d');
  static final RegExp _special = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_email.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  static String? username(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Username is required';
    if (v.length > AppConstants.usernameMaxLength) {
      return 'Username must be at most ${AppConstants.usernameMaxLength} characters';
    }
    return null;
  }

  /// Login only checks the DTO constraints — never reject an existing
  /// password for "strength".
  static String? loginPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length > AppConstants.passwordMaxLength) {
      return 'Password must not exceed ${AppConstants.passwordMaxLength} characters';
    }
    return null;
  }

  /// Register — mirrors the backend's validatePasswordStrength().
  static String? strongPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < AppConstants.passwordMinLength) {
      return 'Password must be at least ${AppConstants.passwordMinLength} characters long';
    }
    if (v.length > AppConstants.passwordMaxLength) {
      return 'Password must not exceed ${AppConstants.passwordMaxLength} characters';
    }
    if (!_uppercase.hasMatch(v)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!_lowercase.hasMatch(v)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!_digit.hasMatch(v)) {
      return 'Password must contain at least one digit';
    }
    if (!_special.hasMatch(v)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }
}

import 'package:flutter/material.dart';

import '../../../../core/util/responsive.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const InputField({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(context.defaultRadius * 1.5);

    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: 4,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmit(),
      style: TextStyle(fontSize: context.sp(17, min: 16, max: 20)),
      decoration: InputDecoration(
        hintText: 'Type a word or phrase',
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.wp(4),
          vertical: context.hp(1.8),
        ),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        // Clear button only shows when there is text; rebuilds just this icon.
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: controller.clear,
                ),
        ),
      ),
    );
  }
}

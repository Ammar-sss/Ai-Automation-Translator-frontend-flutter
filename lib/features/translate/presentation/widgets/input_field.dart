import 'package:material_ui/material_ui.dart';

import '../../../../core/util/responsive.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final VoidCallback onSubmit;

  const InputField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(18);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      minLines: 2,
      maxLines: 5,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmit(),
      style: text.bodyLarge?.copyWith(
        fontSize: context.sp(17, min: 16, max: 20),
        height: 1.35,
      ),
      decoration: InputDecoration(
        hintText: 'Enter text, word, or sentence…',
        hintStyle: text.bodyLarge?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
          fontSize: context.sp(16, min: 15, max: 18),
        ),
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.wp(4),
          vertical: context.hp(1.8),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10, top: 12),
          child: Align(
            alignment: Alignment.topCenter,
            widthFactor: 1.0,
            child: Icon(
              Icons.edit_note_rounded,
              color: scheme.primary,
              size: 24,
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.primary, width: 1.8),
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Clear input',
                  icon: Icon(
                    Icons.cancel_rounded,
                    color: scheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: controller.clear,
                ),
        ),
      ),
    );
  }
}

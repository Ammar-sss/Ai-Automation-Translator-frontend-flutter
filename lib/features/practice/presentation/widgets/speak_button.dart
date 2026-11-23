import 'package:material_ui/material_ui.dart';

class SpeakButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const SpeakButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton.filledTonal(
      onPressed: onPressed,
      style: IconButton.styleFrom(backgroundColor: scheme.surfaceContainerHigh),
      icon: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.primary,
              ),
            )
          : Icon(Icons.volume_up_rounded, size: 20, color: scheme.primary),
      tooltip: 'Pronounce word',
    );
  }
}

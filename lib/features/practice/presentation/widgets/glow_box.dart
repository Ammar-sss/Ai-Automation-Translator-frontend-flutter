import 'package:cupertino_ui/cupertino_ui.dart';

class GlowBox extends StatelessWidget {
  final Color color;
  final double radius;
  final Widget child;

  const GlowBox({
    super.key,
    required this.color,
    required this.radius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

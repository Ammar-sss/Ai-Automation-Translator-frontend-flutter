import 'package:material_ui/material_ui.dart';
import 'package:smart_translator_test/features/practice/presentation/utils/practice_text_utils.dart';

/// Text that follows its own script direction (Arabic reads right to left).
class DirectionalText extends StatelessWidget {
  final String data;
  final TextStyle? style;

  const DirectionalText(this.data, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        data,
        textDirection: isRtl(data) ? TextDirection.rtl : TextDirection.ltr,
        style: style,
      ),
    );
  }
}

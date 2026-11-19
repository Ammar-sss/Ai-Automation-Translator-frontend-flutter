import 'package:material_ui/material_ui.dart';
import 'package:smart_translator_test/core/util/responsive.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.screenPadding,
        child: Text(
          "Home page",
          style: TextStyle(
            fontSize: context.sp(20, min: 16, max: 24),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator_test/core/util/responsive.dart';
import 'package:smart_translator_test/features/user/presentation/widgets/setting_group.dart';
import 'package:smart_translator_test/features/user/presentation/widgets/setting_switch.dart';
import 'package:smart_translator_test/features/user/presentation/widgets/setting_title.dart';

import '../controller/theme_cubit.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  static const _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
  ];

  String _selectedLanguage = 'English';

  Future<void> _pickLanguage() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  'Select language',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              for (final lang in _languages)
                ListTile(
                  title: Text(lang),
                  trailing: lang == _selectedLanguage
                      ? Icon(Icons.check_rounded, color: scheme.primary)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, lang),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (picked != null && mounted) setState(() => _selectedLanguage = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        scrolledUnderElevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isTablet ? 650 : double.infinity,
          ),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              SettingsGroup(
                title: 'Preferences',
                children: [
                  SettingTile(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: _selectedLanguage,
                    onTap: _pickLanguage,
                  ),
                  BlocSelector<ThemeCubit, ThemeState, bool>(
                    selector: (state) => state.themeMode == ThemeMode.dark,
                    builder: (context, isDarkMode) {
                      return SettingSwitch(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark theme',
                        subtitle: 'Switch between light and dark',
                        value: isDarkMode,
                        onChanged: (value) {
                          context.read<ThemeCubit>().toggleTheme(value);
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

class EditProfileSheet extends StatefulWidget {
  final String name;
  const EditProfileSheet({super.key, required this.name});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.name,
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;
    // Hook up the real update call here.
    Navigator.pop(context, true);
  }

  InputDecoration _decoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: _decoration(
                context,
                'Full name',
                Icons.person_outline,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text(
                'Save changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

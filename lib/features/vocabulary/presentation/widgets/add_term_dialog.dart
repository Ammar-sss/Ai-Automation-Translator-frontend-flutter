import 'package:material_ui/material_ui.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/example.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/example_definitions.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term.dart';
import 'package:smart_translator_test/features/vocabulary/data/models/term_definitions.dart';

class AddTermDialog extends StatefulWidget {
  final String folderName;

  const AddTermDialog({super.key, required this.folderName});

  @override
  State<AddTermDialog> createState() => AddTermDialogState();
}

class AddTermDialogState extends State<AddTermDialog> {
  late final TextEditingController _wordController;
  late final TextEditingController _definitionController;
  late final TextEditingController _exampleController;
  late final TextEditingController _exampleDefinitionController;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController();
    _definitionController = TextEditingController();
    _exampleController = TextEditingController();
    _exampleDefinitionController = TextEditingController();
  }

  @override
  void dispose() {
    _wordController.dispose();
    _definitionController.dispose();
    _exampleController.dispose();
    _exampleDefinitionController.dispose();
    super.dispose();
  }

  void _submit() {
    final word = _wordController.text.trim();
    if (word.isEmpty) return;

    final defText = _definitionController.text.trim();
    final exText = _exampleController.text.trim();
    final exDefText = _exampleDefinitionController.text.trim();

    final term = Term(
      id: 0,
      termWord: word,
      termDefinitions: defText.isNotEmpty
          ? {TermDefinition(id: 0, definition: defText)}
          : {},
      termExamples: exText.isNotEmpty
          ? {Example(id: 0, exampleSentence: exText)}
          : {},
      exampleDefinitions: exDefText.isNotEmpty
          ? {ExampleDefinition(id: 0, exampleDefinition: exDefText)}
          : {},
    );

    Navigator.pop(context, term);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(Icons.add_circle_outline_rounded, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Add Term to ${widget.folderName}',
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _wordController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Term / Word *',
                hintText: 'e.g. sister',
                prefixIcon: const Icon(Icons.text_fields_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _definitionController,
              decoration: InputDecoration(
                labelText: 'Definition (optional)',
                hintText: 'e.g. A female sibling',
                prefixIcon: const Icon(Icons.notes_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _exampleController,
              decoration: InputDecoration(
                labelText: 'Example sentence (optional)',
                hintText: 'e.g. My sister is older than me',
                prefixIcon: const Icon(Icons.format_quote_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _exampleDefinitionController,
              decoration: InputDecoration(
                labelText: 'Example definition (optional)',
                hintText: 'e.g. اختي أكبر مني سنًا',
                prefixIcon: const Icon(Icons.translate_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Add Term'),
        ),
      ],
    );
  }
}

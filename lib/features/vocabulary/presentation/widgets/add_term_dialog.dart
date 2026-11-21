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
  final _word = TextEditingController();
  final _definition = TextEditingController();
  final _example = TextEditingController();
  final _exampleDefinition = TextEditingController();

  @override
  void dispose() {
    _word.dispose();
    _definition.dispose();
    _example.dispose();
    _exampleDefinition.dispose();
    super.dispose();
  }

  void _submit() {
    final word = _word.text.trim();
    if (word.isEmpty) return;

    final def = _definition.text.trim();
    final ex = _example.text.trim();
    final exDef = _exampleDefinition.text.trim();

    Navigator.pop(
      context,
      Term(
        id: 0,
        termWord: word,
        termDefinitions: def.isNotEmpty
            ? {TermDefinition(id: 0, definition: def)}
            : {},
        termExamples: ex.isNotEmpty
            ? {Example(id: 0, exampleSentence: ex)}
            : {},
        exampleDefinitions: exDef.isNotEmpty
            ? {ExampleDefinition(id: 0, exampleDefinition: exDef)}
            : {},
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    bool autofocus = false,
    bool last = false,
  }) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(labelText: label, hintText: hint),
      onSubmitted: last ? (_) => _submit() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add to ${widget.folderName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_word, 'Word *', hint: 'e.g. sister', autofocus: true),
            const SizedBox(height: 12),
            _field(_definition, 'Definition', hint: 'e.g. A female sibling'),
            const SizedBox(height: 12),
            _field(_example, 'Example sentence'),
            const SizedBox(height: 12),
            _field(_exampleDefinition, 'Example translation', last: true),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _word,
          builder: (_, value, _) => FilledButton(
            onPressed: value.text.trim().isEmpty ? null : _submit,
            child: const Text('Add'),
          ),
        ),
      ],
    );
  }
}

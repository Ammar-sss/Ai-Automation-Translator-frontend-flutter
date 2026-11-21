import 'package:material_ui/material_ui.dart';

class FolderInputDialog extends StatefulWidget {
  final String title;
  final String? initialValue;
  final String actionLabel;

  const FolderInputDialog({
    super.key,
    required this.title,
    this.initialValue,
    required this.actionLabel,
  });

  @override
  State<FolderInputDialog> createState() => FolderInputDialogState();
}

class FolderInputDialogState extends State<FolderInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          hintText: 'Folder name',
          counterText: '',
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        // Disabled until there is something to save.
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (_, value, _) => FilledButton(
            onPressed: value.text.trim().isEmpty ? null : _submit,
            child: Text(widget.actionLabel),
          ),
        ),
      ],
    );
  }
}

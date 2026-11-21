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
    if (text.isNotEmpty) {
      Navigator.pop(context, text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(Icons.create_new_folder_outlined, color: scheme.primary),
          const SizedBox(width: 10),
          Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: 'Folder name',
          prefixIcon: const Icon(Icons.folder_open_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.actionLabel)),
      ],
    );
  }
}

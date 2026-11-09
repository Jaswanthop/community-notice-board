import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../models/notice.dart';
import '../models/notice_category.dart';

class NoticeFormScreen extends StatefulWidget {
  const NoticeFormScreen({super.key, this.existing});

  final Notice? existing;

  @override
  State<NoticeFormScreen> createState() => _NoticeFormScreenState();
}

class _NoticeFormScreenState extends State<NoticeFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late NoticeCategory _category;
  late bool _isPinned;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _bodyController = TextEditingController(text: existing?.body ?? '');
    _category = existing?.category ?? NoticeCategory.general;
    _isPinned = existing?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final state = AppScope.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (_isEditing) {
      await state.updateNotice(
        widget.existing!.copyWith(
          title: title,
          body: body,
          category: _category,
          isPinned: _isPinned,
        ),
      );
    } else {
      await state.createNotice(
        title: title,
        body: body,
        category: _category,
        isPinned: _isPinned,
      );
    }

    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? 'Notice updated'
              : 'Notice posted to the community board',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit notice' : 'New notice')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: <Widget>[
            Text(
              _isEditing ? 'Update your notice' : 'Share with your neighbors',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Keep it clear and friendly — this appears on the community '
              'board for everyone nearby.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              key: const Key('notice-title-field'),
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              maxLength: 80,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Streetlight out on Oak Avenue',
              ),
              validator: (String? value) {
                final title = value?.trim() ?? '';
                if (title.isEmpty) return 'Add a short title';
                if (title.length < 4) return 'Title is a little too short';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const Key('notice-body-field'),
              controller: _bodyController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 6,
              maxLines: 12,
              maxLength: 1200,
              decoration: const InputDecoration(
                labelText: 'Details',
                hintText: 'What, when, where, and who to contact…',
                alignLabelWithHint: true,
              ),
              validator: (String? value) {
                final body = value?.trim() ?? '';
                if (body.isEmpty) return 'Tell neighbors a little more';
                if (body.length < 10) {
                  return 'Add a little more detail (at least 10 characters)';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text('Category', style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final category in NoticeCategory.values)
                  _CategoryChoice(
                    category: category,
                    selected: _category == category,
                    onSelected: () => setState(() => _category = category),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: SwitchListTile.adaptive(
                value: _isPinned,
                onChanged: (bool value) => setState(() => _isPinned = value),
                secondary: const Icon(Icons.push_pin_outlined),
                title: const Text('Pin to top'),
                subtitle: const Text(
                  'Keep this notice above the rest of the board',
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
            ),
            const SizedBox(height: 26),
            SizedBox(
              height: 54,
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('submit-notice-button'),
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isEditing
                            ? Icons.check_rounded
                            : Icons.send_rounded,
                      ),
                label: Text(
                  _saving
                      ? 'Saving…'
                      : (_isEditing ? 'Save changes' : 'Post notice'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChoice extends StatelessWidget {
  const _CategoryChoice({
    required this.category,
    required this.selected,
    required this.onSelected,
  });

  final NoticeCategory category;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = category.foregroundFor(theme.brightness);

    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      avatar: Icon(
        category.icon,
        size: 16,
        color: selected ? accent : theme.colorScheme.onSurfaceVariant,
      ),
      label: Text(category.label),
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? accent : theme.colorScheme.onSurfaceVariant,
      ),
      selectedColor: category.backgroundFor(theme.brightness),
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      side: BorderSide(
        color: selected
            ? accent.withValues(alpha: 0.45)
            : theme.colorScheme.outlineVariant,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }
}

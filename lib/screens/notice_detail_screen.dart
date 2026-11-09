import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../models/comment.dart';
import '../models/notice.dart';
import '../utils/formatters.dart';
import '../widgets/category_badge.dart';
import '../widgets/empty_state.dart';
import 'notice_form_screen.dart';

Future<void> openNoticeDetail(BuildContext context, String noticeId) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => NoticeDetailScreen(
        noticeId: noticeId,
      ),
    ),
  );
}

class NoticeDetailScreen extends StatefulWidget {
  const NoticeDetailScreen({super.key, required this.noticeId});

  final String noticeId;

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _sendComment(Notice notice) {
    final text = _commentController.text;
    if (text.trim().isEmpty) return;
    AppScope.of(context).addComment(notice.id, text);
    _commentController.clear();
  }

  Future<void> _edit(Notice notice) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => NoticeFormScreen(existing: notice),
      ),
    );
  }

  Future<void> _confirmDelete(Notice notice) async {
    final state = AppScope.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete this notice?'),
          content: Text(
            '“${notice.title}” will be removed from the board on this device.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await state.deleteNotice(notice.id);
    if (!mounted) return;
    navigator.pop();
    messenger.showSnackBar(const SnackBar(content: Text('Notice deleted')));
  }

  void _handleMenuSelection(String action, Notice notice) {
    final state = AppScope.of(context);
    switch (action) {
      case 'pin':
        state.togglePin(notice.id);
      case 'edit':
        _edit(notice);
      case 'delete':
        _confirmDelete(notice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = AppScope.of(context);
    final notice = state.noticeById(widget.noticeId);

    if (notice == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.delete_outline_rounded,
          title: 'Notice removed',
          message: 'This notice is no longer on the board.',
          action: FilledButton.tonal(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Back to board'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice'),
        actions: <Widget>[
          IconButton(
            onPressed: () => state.toggleBookmark(notice.id),
            tooltip: notice.isBookmarked ? 'Remove bookmark' : 'Save notice',
            color: notice.isBookmarked ? scheme.primary : null,
            icon: Icon(
              notice.isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Notice options',
            onSelected: (value) => _handleMenuSelection(value, notice),
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'pin',
                  child: _MenuRow(
                    icon: notice.isPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                    label: notice.isPinned ? 'Unpin notice' : 'Pin to top',
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: _MenuRow(
                    icon: Icons.edit_outlined,
                    label: 'Edit notice',
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: _MenuRow(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete notice',
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: <Widget>[
          _CategoryHero(notice: notice),
          const SizedBox(height: 20),
          Text(
            notice.title,
            style: theme.textTheme.headlineSmall?.copyWith(height: 1.2),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 18,
                backgroundColor: scheme.secondaryContainer,
                child: Text(
                  initialsOf(notice.author),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      notice.author,
                      style: theme.textTheme.labelLarge,
                    ),
                    Text(
                      'Posted ${timeAgo(notice.createdAt)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              CategoryBadge(category: notice.category, dense: true),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            notice.body,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
          const SizedBox(height: 28),
          _CommentsSection(
            comments: notice.comments,
            commentCount: notice.commentCount,
          ),
        ],
      ),
      bottomNavigationBar: _CommentComposer(
        controller: _commentController,
        onSend: () => _sendComment(notice),
      ),
    );
  }
}

class _CategoryHero extends StatelessWidget {
  const _CategoryHero({required this.notice});

  final Notice notice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = notice.category.color;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            color,
            Color.lerp(color, Colors.black, 0.28)!,
          ],
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(notice.category.icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  notice.category.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  fullDate(notice.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          if (notice.isPinned)
            Tooltip(
              message: 'Pinned notice',
              child: Icon(
                Icons.push_pin_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

class _CommentsSection extends StatelessWidget {
  const _CommentsSection({
    required this.comments,
    required this.commentCount,
  });

  final List<Comment> comments;
  final int commentCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('Comments', style: theme.textTheme.titleMedium),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$commentCount',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: comments.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    'No comments yet — be the first to reply.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                )
              : Column(
                  children: <Widget>[
                    for (int i = 0; i < comments.length; i++) ...<Widget>[
                      if (i > 0) const Divider(),
                      _CommentTile(comment: comments[i]),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 15,
            backgroundColor: scheme.primaryContainer,
            child: Text(
              initialsOf(comment.author),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        comment.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo(comment.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (BuildContext context, TextEditingValue value, _) {
              final canSend = value.text.trim().isNotEmpty;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment…',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: canSend ? onSend : null,
                    tooltip: 'Send comment',
                    icon: const Icon(Icons.send_rounded, size: 20),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}

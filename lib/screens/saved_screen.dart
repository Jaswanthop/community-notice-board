import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../widgets/empty_state.dart';
import '../widgets/notice_card.dart';
import 'notice_detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key, required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final saved = AppScope.of(context).savedNotices;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Saved', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Notices you bookmarked for later',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (saved.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.bookmark_border_rounded,
                title: 'Nothing saved yet',
                message:
                    'Tap the bookmark icon on any notice to keep it here for '
                    'later.',
                action: FilledButton.tonal(
                  onPressed: onBrowse,
                  child: const Text('Browse the board'),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverList.separated(
                itemCount: saved.length,
                itemBuilder: (BuildContext context, int index) {
                  final notice = saved[index];
                  return NoticeCard(
                    notice: notice,
                    onTap: () => openNoticeDetail(context, notice.id),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 12);
                },
              ),
            ),
        ],
      ),
    );
  }
}

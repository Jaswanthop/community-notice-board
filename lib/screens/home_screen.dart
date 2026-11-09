import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../models/notice_category.dart';
import '../utils/formatters.dart';
import '../utils/notice_filters.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/notice_card.dart';
import '../widgets/notice_search_field.dart';
import 'notice_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  NoticeCategory? _category;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _category = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = AppScope.of(context);

    final visible = filterNotices(
      state.sortedNotices,
      query: _query,
      category: _category,
    );
    final hasFilters = _query.trim().isNotEmpty || _category != null;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _FeedHeader(
              userName: state.userName,
              noticeCount: state.notices.length,
              controller: _searchController,
              onSearchChanged: (value) => setState(() => _query = value),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: CategoryFilterBar(
                selected: _category,
                onSelected: (category) => setState(() => _category = category),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: <Widget>[
                  Text(
                    'Latest notices',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Text(
                    '${visible.length} of ${state.notices.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (visible.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: hasFilters ? 'No notices match' : 'The board is empty',
                message: hasFilters
                    ? 'Try a different keyword, or clear the filters to see '
                          'everything on the board.'
                    : 'Be the first to share something with your neighbors.',
                action: hasFilters
                    ? TextButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.filter_alt_off_outlined),
                        label: const Text('Clear filters'),
                      )
                    : null,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 104),
              sliver: SliverList.separated(
                itemCount: visible.length,
                itemBuilder: (BuildContext context, int index) {
                  final notice = visible[index];
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

class _FeedHeader extends StatelessWidget {
  const _FeedHeader({
    required this.userName,
    required this.noticeCount,
    required this.controller,
    required this.onSearchChanged,
  });

  final String userName;
  final int noticeCount;
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[scheme.primaryContainer, scheme.surface],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.campaign_rounded,
                  size: 18,
                  color: scheme.onPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'NOTICE BOARD',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                    ),
                  ),
                  Text(
                    'Riverside Community',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              CircleAvatar(
                radius: 18,
                backgroundColor: scheme.surface,
                child: Text(
                  initialsOf(userName),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            '${greetingFor(DateTime.now())},',
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            noticeCount == 1
                ? '1 notice on the community board'
                : '$noticeCount notices from your neighbors',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          NoticeSearchField(
            controller: controller,
            onChanged: onSearchChanged,
          ),
        ],
      ),
    );
  }
}

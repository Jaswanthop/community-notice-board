import '../models/comment.dart';
import '../models/notice.dart';
import '../models/notice_category.dart';

/// Sample content shown the first time the app runs.
List<Notice> buildDemoNotices({DateTime? now}) {
  final reference = now ?? DateTime.now();

  return <Notice>[
    Notice(
      id: 'demo-cleanup',
      title: 'Community clean-up day this Saturday',
      body:
          'Meet us at the Riverside Park entrance at 9:00 AM. Gloves, bags '
          'and grabbers are provided by the residents association. We will '
          'split into small teams and wrap up by noon with coffee and '
          'snacks. Families and kids are welcome — every pair of hands '
          'helps. Bring a reusable water bottle and wear closed shoes.',
      author: 'Priya Sharma',
      category: NoticeCategory.events,
      createdAt: reference.subtract(const Duration(days: 2, hours: 3)),
      isPinned: true,
      comments: <Comment>[
        Comment(
          id: 'demo-cleanup-c1',
          author: 'Daniel Okafor',
          text: 'Count me in! I can bring an extra pair of gloves.',
          createdAt: reference.subtract(const Duration(days: 2, hours: 1)),
        ),
        Comment(
          id: 'demo-cleanup-c2',
          author: 'Priya Sharma',
          text: 'Wonderful, thank you Daniel. See you at the gate!',
          createdAt: reference.subtract(const Duration(days: 1, hours: 20)),
        ),
      ],
    ),
    Notice(
      id: 'demo-water',
      title: 'Water supply maintenance on Maple Street',
      body:
          'The municipal water team will shut off supply on Tuesday between '
          '10:00 AM and 2:00 PM while they replace a section of the main '
          'line. Please fill a few containers in advance and avoid running '
          'washing machines during that window. Buildings on Cedar Lane may '
          'see lower pressure as well.',
      author: 'Ravi Menon',
      category: NoticeCategory.general,
      createdAt: reference.subtract(const Duration(days: 1, hours: 4)),
      comments: <Comment>[
        Comment(
          id: 'demo-water-c1',
          author: 'Helena Fischer',
          text: 'Thanks for the heads-up. Will the schedule hold if it rains?',
          createdAt: reference.subtract(const Duration(hours: 20)),
        ),
      ],
    ),
    Notice(
      id: 'demo-cat',
      title: 'Lost: grey tabby cat near Riverside Park',
      body:
          'Mochi slipped out through the balcony door on Sunday evening. She '
          'is a small grey tabby with a white chest, a red collar and a '
          'slightly bent left ear. She is shy but friendly with treats. If '
          'you spot her, please call 555-0142 or leave a comment here. Thank '
          'you from the bottom of our hearts.',
      author: 'Anita Rao',
      category: NoticeCategory.lostFound,
      createdAt: reference.subtract(const Duration(hours: 6)),
      comments: <Comment>[
        Comment(
          id: 'demo-cat-c1',
          author: 'Marcus Lee',
          text: 'I saw a grey cat behind the community hall around 7 PM.',
          createdAt: reference.subtract(const Duration(hours: 4)),
        ),
        Comment(
          id: 'demo-cat-c2',
          author: 'Anita Rao',
          text: 'That sounds like her! Heading over now, thank you!',
          createdAt: reference.subtract(const Duration(hours: 3)),
        ),
      ],
    ),
    Notice(
      id: 'demo-yoga',
      title: 'Free beginner yoga at the community hall',
      body:
          'Start your Sunday gently with a free 60-minute beginner yoga '
          'session. We meet in the small hall at 7:00 AM. Mats are available '
          'but feel free to bring your own. No experience needed — just '
          'comfortable clothes and a water bottle.',
      author: 'Karan Patel',
      category: NoticeCategory.events,
      createdAt: reference.subtract(const Duration(days: 3, hours: 2)),
      comments: const <Comment>[],
    ),
    Notice(
      id: 'demo-plumber',
      title: 'Reliable plumber available this week',
      body:
          'My neighbor Sam is a licensed plumber with a free slot this week. '
          'He fixed our kitchen leak and the pressure valve in under an hour. '
          'Reasonable rates, and he is happy to give a quote before starting. '
          'Reply here and I will pass along his number.',
      author: 'Meera Joshi',
      category: NoticeCategory.services,
      createdAt: reference.subtract(const Duration(hours: 26)),
      comments: <Comment>[],
    ),
    Notice(
      id: 'demo-bikes',
      title: 'Reminder: lock your bicycles',
      body:
          'Two bicycles were reported stolen from the east entrance last '
          'night. Please use the racks in front of the lobby and double-check '
          'your locks. If you notice anyone loitering around the bike area, '
          'let the security desk know right away.',
      author: 'Security Desk',
      category: NoticeCategory.safety,
      createdAt: reference.subtract(const Duration(hours: 30)),
      comments: const <Comment>[],
    ),
    Notice(
      id: 'demo-market',
      title: 'Farmers market looking for vendors',
      body:
          'The Sunday farmers market has a few stalls open for the new '
          'season. We are looking for homemade bakes, preserves, crafts and '
          'small-scale growers. Stalls are free for the first month. Email '
          'market@riverside.org or comment below and we will get back to you.',
      author: 'Riverside Market',
      category: NoticeCategory.marketplace,
      createdAt: reference.subtract(const Duration(days: 4, hours: 5)),
      comments: const <Comment>[],
    ),
  ];
}

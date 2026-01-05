import 'package:go_router/go_router.dart';
import 'package:k_lit/features/auth/pages/my_page.dart';
import 'package:k_lit/features/auth/widgets/auth_gate.dart';
import 'package:k_lit/features/collections/pages/collection_detail_page.dart';
import 'package:k_lit/features/collections/pages/collection_list_page.dart';
import 'package:k_lit/features/collections/pages/search_page.dart';
import 'package:k_lit/features/stories/pages/story_reader_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthGate()),
    GoRoute(
      path: '/collections',
      builder: (context, state) => const CollectionListPage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) =>
              CollectionDetailPage(collectionId: state.pathParameters['id'] ?? ''),
        ),
      ],
    ),
    GoRoute(
      path: '/stories/:id',
      builder: (context, state) {
        final storyId = state.pathParameters['id'] ?? '';
        final hasAccess = state.uri.queryParameters['hasAccess'] == 'true';
        return StoryReaderPage(hasAccess: hasAccess, storyId: storyId);
      },
    ),
    GoRoute(path: '/search', builder: (context, state) => const SearchPage()),
    GoRoute(path: '/my-page', builder: (context, state) => const MyPage()),
  ],
);

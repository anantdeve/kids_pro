import 'package:go_router/go_router.dart';
import '../../presentation/splash/screens/splash_screen.dart';
import '../../presentation/splash/screens/standard_selection_screen.dart';
import '../../presentation/auth/screens/auth_screen.dart';
import '../../presentation/home/screens/main_screen.dart';
import '../../presentation/learning/screens/abc_screen.dart';
import '../../presentation/learning/screens/learning_world_hub_screen.dart';
import '../../presentation/learning/screens/colors_adventure_screen.dart';
import '../../presentation/learning/screens/color_match_screen.dart';
import '../../presentation/learning/screens/color_quest_screen.dart';
import '../../presentation/learning/screens/color_the_magic_screen.dart';
import '../../presentation/learning/screens/number_magic_screen.dart';
import '../../presentation/learning/screens/number_matching_game_screen.dart';
import '../../presentation/learning/screens/count_and_tap_game_screen.dart';
import '../../presentation/learning/screens/missing_number_game_screen.dart';
import '../../presentation/learning/screens/number_puzzle_game_screen.dart';
import '../../presentation/learning/screens/look_and_match_game_screen.dart';
import '../../presentation/learning/screens/alphabet_surprise_screen.dart';
import '../../presentation/quiz/screens/quiz_selection_screen.dart';
import '../../presentation/quiz/screens/magic_quiz_screen.dart';
import '../../presentation/games/screens/fun_games_hub_screen.dart';
import '../../presentation/games/screens/memory_match_screen.dart';
import '../../presentation/games/screens/bubble_pop_screen.dart';
import '../../presentation/games/screens/shadow_matcher_screen.dart';
import '../../presentation/games/screens/magic_paint_screen.dart';
import '../../presentation/learning/screens/magic_story_selection_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/standard-selection',
      builder: (context, state) => const StandardSelectionScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/learning-hub',
      builder: (context, state) => const LearningWorldHubScreen(),
    ),
    GoRoute(
      path: '/colors-adventure',
      builder: (context, state) => const ColorsAdventureScreen(),
    ),
    GoRoute(
      path: '/number-magic',
      builder: (context, state) => const NumberMagicScreen(),
    ),
    GoRoute(
      path: '/number-matching-game',
      builder: (context, state) => const NumberMatchingGameScreen(),
    ),
    GoRoute(
      path: '/count-and-tap-game',
      builder: (context, state) => const CountAndTapGameScreen(),
    ),
    GoRoute(
      path: '/missing-number-game',
      builder: (context, state) => const MissingNumberGameScreen(),
    ),
    GoRoute(
      path: '/number-puzzle-game',
      builder: (context, state) => const NumberPuzzleGameScreen(),
    ),
    GoRoute(
      path: '/look-and-match-game',
      builder: (context, state) => const LookAndMatchGameScreen(),
    ),
    GoRoute(
      path: '/color-match',
      builder: (context, state) => const ColorMatchScreen(),
    ),
    GoRoute(
      path: '/color-quest',
      builder: (context, state) => const ColorQuestScreen(),
    ),
    GoRoute(
      path: '/color-the-magic',
      builder: (context, state) => const ColorTheMagicScreen(),
    ),
    GoRoute(
      path: '/abc',
      builder: (context, state) => const AbcScreen(),
    ),
    GoRoute(
      path: '/alphabet-surprise',
      builder: (context, state) => const AlphabetSurpriseScreen(),
    ),
    GoRoute(
      path: '/quiz-selection',
      builder: (context, state) => const QuizSelectionScreen(),
    ),
    GoRoute(
      path: '/magic-quiz',
      builder: (context, state) {
        final categoryId = int.parse(state.uri.queryParameters['categoryId'] ?? '27');
        final difficulty = state.uri.queryParameters['difficulty'] ?? 'easy';
        return MagicQuizScreen(categoryId: categoryId, difficulty: difficulty);
      },
    ),
    GoRoute(
      path: '/fun-games',
      builder: (context, state) => const FunGamesHubScreen(),
    ),
    GoRoute(
      path: '/memory-match',
      builder: (context, state) => const MemoryMatchScreen(),
    ),
    GoRoute(
      path: '/bubble-pop',
      builder: (context, state) => const BubblePopScreen(),
    ),
    GoRoute(
      path: '/shadow-matcher',
      builder: (context, state) => const ShadowMatcherScreen(),
    ),
    GoRoute(
      path: '/magic-paint',
      builder: (context, state) => const MagicPaintScreen(),
    ),
    GoRoute(
      path: '/magic-story',
      builder: (context, state) => const MagicStorySelectionScreen(),
    ),
    // TODO: Add other routes here (numbers, colors, animals, etc.)
  ],
);

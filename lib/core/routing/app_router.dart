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
import '../../presentation/quiz/screens/api_quiz_screen.dart';
import '../../presentation/games/screens/fun_games_hub_screen.dart';
import '../../presentation/games/screens/memory_match_screen.dart';
import '../../presentation/games/screens/bubble_pop_screen.dart';
import '../../presentation/games/screens/shadow_matcher_screen.dart';
import '../../presentation/games/screens/magic_paint_screen.dart';
import '../../presentation/games/screens/asmr_coloring_screen.dart';
import '../../presentation/games/screens/nuts_sort_puzzle_screen.dart';
import '../../presentation/games/screens/tangle_master_screen.dart';
import '../../presentation/profile/screens/saved_art_gallery_screen.dart';

import '../../presentation/learning/screens/magic_story_selection_screen.dart';
import '../../presentation/learning/screens/match_word_to_picture_screen.dart';
import '../../presentation/learning/screens/listen_and_choose_screen.dart';
import '../../presentation/learning/screens/drag_letters_screen.dart';
import '../../presentation/learning/screens/arithmetic_hub_screen.dart';
import '../../presentation/learning/screens/feed_the_monster_screen.dart';
import '../../presentation/learning/screens/frog_jumps_screen.dart';
import '../../presentation/learning/screens/magic_potions_screen.dart';
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
        final categoryId = int.parse(state.uri.queryParameters['categoryId'] ?? '1');
        final difficulty = state.uri.queryParameters['difficulty'] ?? 'easy';
        return MagicQuizScreen(categoryId: categoryId, difficulty: difficulty);
      },
    ),
    GoRoute(
      path: '/api-quiz',
      builder: (context, state) {
        final categoryId = int.parse(state.uri.queryParameters['categoryId'] ?? '9');
        final difficulty = state.uri.queryParameters['difficulty'] ?? 'easy';
        return ApiQuizScreen(categoryId: categoryId, difficulty: difficulty);
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
      path: '/asmr-coloring',
      builder: (context, state) => const AsmrColoringScreen(),
    ),
    GoRoute(
      path: '/nuts-sort',
      builder: (context, state) => const NutsSortPuzzleScreen(),
    ),
    GoRoute(
      path: '/tangle-master',
      builder: (context, state) => const TangleMasterScreen(),
    ),
    GoRoute(
      path: '/magic-story',
      builder: (context, state) => const MagicStorySelectionScreen(),
    ),
    GoRoute(
      path: '/saved-art',
      builder: (context, state) => const SavedArtGalleryScreen(),
    ),
    GoRoute(
      path: '/match-word',
      builder: (context, state) => const MatchWordToPictureScreen(),
    ),
    GoRoute(
      path: '/listen-word',
      builder: (context, state) => const ListenAndChooseScreen(),
    ),
    GoRoute(
      path: '/drag-letters',
      builder: (context, state) => const DragLettersScreen(),
    ),
    GoRoute(
      path: '/arithmetic-hub',
      builder: (context, state) => const ArithmeticHubScreen(),
    ),
    GoRoute(
      path: '/feed-monster',
      builder: (context, state) => const FeedTheMonsterScreen(),
    ),
    GoRoute(
      path: '/frog-jumps',
      builder: (context, state) => const FrogJumpsScreen(),
    ),
    GoRoute(
      path: '/magic-potions',
      builder: (context, state) => const MagicPotionsScreen(),
    ),
    // TODO: Add other routes here (numbers, colors, animals, etc.)
  ],
);

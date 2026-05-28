import '../../domain/entities/visual_question.dart';

class LocalQuizRepository {
  static const int catAnimals = 1;
  static const int catFruitsVeggies = 2;
  static const int catShapesColors = 3;
  static const int catVehicles = 4;
  static const int catEverydayObjects = 5;
  static const int catPlanetsSpace = 6;
  static const int catToys = 7;
  static const int catFarmFriends = 8;
  static const int catWeather = 9;
  static const int catDinosaurs = 10;
  static const int catOccupations = 11;
  static const int catHealthyFoods = 12;

  static final Map<int, List<VisualQuestion>> _quizzes = {
    catAnimals: [
      VisualQuestion(text: 'Find the cute Dog', emoji: '🐶', options: ['🐱', '🐶', '🐭', '🐹'], correctEmoji: '🐶'),
      VisualQuestion(text: 'Tap on the Blue Bird', emoji: '🐦', options: ['🐦', '🦖', '🦋', '🐝'], correctEmoji: '🐦'),
      VisualQuestion(text: 'Which one lives in Water?', emoji: '🐟', options: ['🦁', '🦅', '🐟', '🐘'], correctEmoji: '🐟'),
      VisualQuestion(text: 'Find the King of the Jungle', emoji: '🦁', options: ['🐯', '🐻', '🦁', '🐺'], correctEmoji: '🦁'),
      VisualQuestion(text: 'Which animal gives Milk?', emoji: '🐄', options: ['🐎', '🐄', '🐖', '🐑'], correctEmoji: '🐄'),
    ],
    catFruitsVeggies: [
      VisualQuestion(text: 'Tap on the Red Apple', emoji: '🍎', options: ['🍎', '🍌', '🍇', '🍐'], correctEmoji: '🍎'),
      VisualQuestion(text: 'Find the Carrot', emoji: '🥕', options: ['🍓', '🥕', '🥦', '🌽'], correctEmoji: '🥕'),
      VisualQuestion(text: 'Which one is a Banana?', emoji: '🍌', options: ['🍉', '🥝', '🍌', '🍒'], correctEmoji: '🍌'),
      VisualQuestion(text: 'Find the Grapes', emoji: '🍇', options: ['🍎', '🍇', '🍓', '🍋'], correctEmoji: '🍇'),
      VisualQuestion(text: 'Tap on the Broccoli', emoji: '🥦', options: ['🌽', '🥬', '🥦', '🍆'], correctEmoji: '🥦'),
    ],
    catShapesColors: [
      VisualQuestion(text: 'Which one is a Red Circle?', emoji: '🔴', options: ['🔴', '🟦', '🔺', '⭐'], correctEmoji: '🔴'),
      VisualQuestion(text: 'Find the Blue Square', emoji: '🟦', options: ['🟢', '🟦', '🔶', '🔻'], correctEmoji: '🟦'),
      VisualQuestion(text: 'Tap on the Yellow Star', emoji: '⭐', options: ['🔴', '🟩', '⭐', '🔷'], correctEmoji: '⭐'),
      VisualQuestion(text: 'Which one is a Green Circle?', emoji: '🟢', options: ['🟣', '🟢', '🟨', '🔻'], correctEmoji: '🟢'),
      VisualQuestion(text: 'Find the Purple Heart', emoji: '💜', options: ['❤️', '💚', '💜', '💙'], correctEmoji: '💜'),
    ],
    catVehicles: [
      VisualQuestion(text: 'Find the Red Car', emoji: '🚗', options: ['🏠', '🌳', '🚗', '🏔️'], correctEmoji: '🚗'),
      VisualQuestion(text: 'Tap on the Airplane', emoji: '✈️', options: ['🚁', '⛵', '✈️', '🚂'], correctEmoji: '✈️'),
      VisualQuestion(text: 'Which one goes in the Water?', emoji: '⛵', options: ['🚗', '⛵', '🛵', '🚲'], correctEmoji: '⛵'),
      VisualQuestion(text: 'Find the Train', emoji: '🚂', options: ['🚀', '🏎️', '🚂', '🛸'], correctEmoji: '🚂'),
      VisualQuestion(text: 'Tap on the Rocket', emoji: '🚀', options: ['🚀', '🚁', '✈️', '🛸'], correctEmoji: '🚀'),
    ],
    catEverydayObjects: [
      VisualQuestion(text: 'Find the Musical Instrument', emoji: '🎸', options: ['🔨', '🎸', '🪚', '🪓'], correctEmoji: '🎸'),
      VisualQuestion(text: 'Which one do we use to see time?', emoji: '⏰', options: ['⏰', '📺', '📻', '🕯️'], correctEmoji: '⏰'),
      VisualQuestion(text: 'Which one is used for Writing?', emoji: '✏️', options: ['🥄', '🧤', '✏️', '🔑'], correctEmoji: '✏️'),
      VisualQuestion(text: 'Find the Winter Clothing', emoji: '🧤', options: ['👕', '🩳', '🧤', '👓'], correctEmoji: '🧤'),
      VisualQuestion(text: 'Tap on the Key', emoji: '🔑', options: ['🔒', '🔑', '🚪', '🪟'], correctEmoji: '🔑'),
    ],
    catPlanetsSpace: [
      VisualQuestion(text: 'Which one is a Planet?', emoji: '🪐', options: ['🪐', '☁️', '🌳', '🏔️'], correctEmoji: '🪐'),
      VisualQuestion(text: 'Find the Sun', emoji: '☀️', options: ['☁️', '🌙', '☀️', '🌈'], correctEmoji: '☀️'),
      VisualQuestion(text: 'Tap on the Crescent Moon', emoji: '🌙', options: ['☀️', '⭐', '🌙', '🌠'], correctEmoji: '🌙'),
      VisualQuestion(text: 'Which one is a Comet?', emoji: '☄️', options: ['🌍', '☄️', '🌌', '🔭'], correctEmoji: '☄️'),
      VisualQuestion(text: 'Find the Earth', emoji: '🌍', options: ['🌕', '🌍', '🪐', '🌑'], correctEmoji: '🌍'),
    ],
    catToys: [
      VisualQuestion(text: 'Find the Teddy Bear', emoji: '🧸', options: ['🚗', '🧸', '🎈', '🪁'], correctEmoji: '🧸'),
      VisualQuestion(text: 'Tap on the Balloon', emoji: '🎈', options: ['🎈', '🪁', '⚽', '🎨'], correctEmoji: '🎈'),
      VisualQuestion(text: 'Which one is a Kite?', emoji: '🪁', options: ['🪀', '🪁', '🧸', '🧩'], correctEmoji: '🪁'),
      VisualQuestion(text: 'Find the Soccer Ball', emoji: '⚽', options: ['🏀', '🎾', '⚽', '🏐'], correctEmoji: '⚽'),
      VisualQuestion(text: 'Tap on the Puzzle', emoji: '🧩', options: ['🎨', '🎲', '🧩', '🎮'], correctEmoji: '🧩'),
    ],
    catFarmFriends: [
      VisualQuestion(text: 'Find the Cow', emoji: '🐄', options: ['🐎', '🐄', '🐑', '🐖'], correctEmoji: '🐄'),
      VisualQuestion(text: 'Tap on the Pig', emoji: '🐖', options: ['🐐', '🐖', '🐓', '🦆'], correctEmoji: '🐖'),
      VisualQuestion(text: 'Which one is a Chicken?', emoji: '🐓', options: ['🐓', '🦆', '🦃', '🦅'], correctEmoji: '🐓'),
      VisualQuestion(text: 'Find the Sheep', emoji: '🐑', options: ['🐑', '🐐', '🐎', '🐄'], correctEmoji: '🐑'),
      VisualQuestion(text: 'Tap on the Tractor', emoji: '🚜', options: ['🚗', '🚜', '🚚', '🚲'], correctEmoji: '🚜'),
    ],
    catWeather: [
      VisualQuestion(text: 'Find the Rain Cloud', emoji: '🌧️', options: ['☀️', '🌧️', '❄️', '🌪️'], correctEmoji: '🌧️'),
      VisualQuestion(text: 'Tap on the Snowman', emoji: '⛄', options: ['⛄', '☀️', '☔', '🌈'], correctEmoji: '⛄'),
      VisualQuestion(text: 'Which one is a Rainbow?', emoji: '🌈', options: ['🌈', '☀️', '☁️', '🌩️'], correctEmoji: '🌈'),
      VisualQuestion(text: 'Find the Lightning', emoji: '⚡', options: ['🔥', '⚡', '💧', '❄️'], correctEmoji: '⚡'),
      VisualQuestion(text: 'Tap on the Umbrella', emoji: '☔', options: ['☔', '🧥', '👢', '🧣'], correctEmoji: '☔'),
    ],
    catDinosaurs: [
      VisualQuestion(text: 'Find the T-Rex', emoji: '🦖', options: ['🦖', '🦕', '🐊', '🐉'], correctEmoji: '🦖'),
      VisualQuestion(text: 'Tap on the Brachiosaurus', emoji: '🦕', options: ['🦕', '🦖', '🐢', '🦎'], correctEmoji: '🦕'),
      VisualQuestion(text: 'Which one is a Dinosaur Egg?', emoji: '🥚', options: ['🥚', '🦴', '🥩', '🐾'], correctEmoji: '🥚'),
      VisualQuestion(text: 'Find the Volcano', emoji: '🌋', options: ['🏔️', '🌋', '⛺', '🏝️'], correctEmoji: '🌋'),
      VisualQuestion(text: 'Tap on the Bone', emoji: '🦴', options: ['🦴', '🍗', '🍖', '🥩'], correctEmoji: '🦴'),
    ],
    catOccupations: [
      VisualQuestion(text: 'Find the Doctor', emoji: '👨‍⚕️', options: ['👨‍⚕️', '👮', '👨‍🏫', '👨‍🍳'], correctEmoji: '👨‍⚕️'),
      VisualQuestion(text: 'Tap on the Police Officer', emoji: '👮', options: ['👮', '👷', '👨‍🚒', '👨‍🌾'], correctEmoji: '👮'),
      VisualQuestion(text: 'Which one is a Firefighter?', emoji: '👨‍🚒', options: ['👨‍🚒', '👨‍🚀', '👨‍🎨', '👨‍🔧'], correctEmoji: '👨‍🚒'),
      VisualQuestion(text: 'Find the Chef', emoji: '👨‍🍳', options: ['👨‍🍳', '👨‍🏫', '👨‍🔬', '👨‍🚀'], correctEmoji: '👨‍🍳'),
      VisualQuestion(text: 'Tap on the Astronaut', emoji: '👨‍🚀', options: ['👨‍🚀', '👨‍✈️', '👨‍⚖️', '🦸‍♂️'], correctEmoji: '👨‍🚀'),
    ],
    catHealthyFoods: [
      VisualQuestion(text: 'Find the Salad', emoji: '🥗', options: ['🥗', '🍔', '🍕', '🌭'], correctEmoji: '🥗'),
      VisualQuestion(text: 'Tap on the Water', emoji: '💧', options: ['🥤', '💧', '🧃', '☕'], correctEmoji: '💧'),
      VisualQuestion(text: 'Which one is a Tomato?', emoji: '🍅', options: ['🍅', '🥔', '🧅', '🍄'], correctEmoji: '🍅'),
      VisualQuestion(text: 'Find the Milk', emoji: '🥛', options: ['🥛', '🧃', '🍵', '🥤'], correctEmoji: '🥛'),
      VisualQuestion(text: 'Tap on the Strawberry', emoji: '🍓', options: ['🍓', '🍒', '🫐', '🍉'], correctEmoji: '🍓'),
    ],
  };

  List<VisualQuestion> getQuestionsForCategory(int categoryId) {
    // If the category doesn't exist, fallback to animals
    final questions = _quizzes[categoryId] ?? _quizzes[catAnimals]!;
    
    // We recreate the VisualQuestion objects to ensure options are freshly shuffled
    // because VisualQuestion shuffles its options on creation.
    final freshQuestions = questions.map((q) => VisualQuestion(
      text: q.text,
      emoji: q.emoji,
      options: List.from(q.options), // this will get shuffled in constructor
      correctEmoji: q.correctEmoji,
    )).toList();
    
    freshQuestions.shuffle();
    return freshQuestions;
  }
}

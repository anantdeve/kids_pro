import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/child_standard.dart';

final childStandardProvider = AsyncNotifierProvider<ChildStandardNotifier, ChildStandard?>(() {
  return ChildStandardNotifier();
});

class ChildStandardNotifier extends AsyncNotifier<ChildStandard?> {
  static const String _storageKey = 'child_standard_selection';

  @override
  Future<ChildStandard?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final String? standardName = prefs.getString(_storageKey);

    if (standardName != null) {
      // Find the matching enum value
      return ChildStandard.values.firstWhere(
        (e) => e.name == standardName,
        orElse: () => ChildStandard.standard1, // Default fallback if not found
      );
    }
    
    // Return null to indicate no standard has been selected yet
    return null;
  }

  Future<void> updateStandard(ChildStandard newStandard) async {
    state = AsyncData(newStandard);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, newStandard.name);
  }
}

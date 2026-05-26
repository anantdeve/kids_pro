enum ChildStandard {
  standard1, // Age 5-6
  standard2, // Age 6-7
  standard3, // Age 7-8
}

extension ChildStandardExtension on ChildStandard {
  String get displayName {
    switch (this) {
      case ChildStandard.standard1:
        return 'Standard 1 (Age 5-6)';
      case ChildStandard.standard2:
        return 'Standard 2 (Age 6-7)';
      case ChildStandard.standard3:
        return 'Standard 3 (Age 7-8)';
    }
  }
}

class PlateExtractor {
  static final RegExp _primaryPattern = RegExp(r'[A-Z]{2,3}[\s-]?[0-9]{2,4}[\s-]?[A-Z]{1,2}');
  static final RegExp _secondaryPattern = RegExp(r'[A-Z]{2,3}[0-9]{3,4}');

  static String? extractPlate(String rawText) {
    if (rawText.isEmpty) return null;

    final cleaned = rawText
        .replaceAll(RegExp(r'[^A-Za-z0-9\s-]'), '')
        .toUpperCase()
        .trim();

    final primaryMatch = _primaryPattern.firstMatch(cleaned);
    if (primaryMatch != null) {
      return primaryMatch.group(0)!.replaceAll(RegExp(r'[\s-]'), '');
    }

    final secondaryMatch = _secondaryPattern.firstMatch(cleaned);
    if (secondaryMatch != null) {
      return secondaryMatch.group(0);
    }

    final words = cleaned.split(RegExp(r'[\s,]+'));
    for (final word in words) {
      final cleanedWord = word.replaceAll(RegExp(r'[^A-Z0-9]'), '');
      if (cleanedWord.length >= 5) {
        final m1 = _primaryPattern.firstMatch(cleanedWord);
        if (m1 != null) return m1.group(0)!.replaceAll(RegExp(r'[\s-]'), '');
        final m2 = _secondaryPattern.firstMatch(cleanedWord);
        if (m2 != null) return m2.group(0);
      }
    }

    return null;
  }

  static bool isValidPlate(String plate) {
    if (plate.isEmpty) return false;
    final cleaned = plate.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
    return _primaryPattern.hasMatch(cleaned) || _secondaryPattern.hasMatch(cleaned);
  }
}

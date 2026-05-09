class LetterData {
  static const Map<String, int> scores = {
    'A': 1, 'B': 3, 'C': 4, 'Ç': 4, 'D': 3, 'E': 1,
    'F': 7, 'G': 5, 'Ğ': 8, 'H': 5, 'I': 2, 'İ': 1,
    'J': 10, 'K': 1, 'L': 1, 'M': 2, 'N': 1, 'O': 2,
    'Ö': 7, 'P': 5, 'R': 1, 'S': 2, 'Ş': 4, 'T': 1,
    'U': 2, 'Ü': 3, 'V': 7, 'Y': 3, 'Z': 4,
  };

  // Frekans ağırlıkları - yüksek = daha sık
  static const List<MapEntry<String, int>> frequencies = [
    MapEntry('A', 12),
    MapEntry('E', 9),
    MapEntry('İ', 8),
    MapEntry('L', 7),
    MapEntry('R', 7),
    MapEntry('N', 7),
    MapEntry('K', 6),
    MapEntry('M', 5),
    MapEntry('T', 5),
    MapEntry('S', 5),
    MapEntry('Y', 4),
    MapEntry('D', 4),
    MapEntry('B', 3),
    MapEntry('U', 3),
    MapEntry('I', 3),
    MapEntry('Ü', 3),
    MapEntry('Ç', 2),
    MapEntry('V', 2),
    MapEntry('G', 2),
    MapEntry('H', 2),
    MapEntry('O', 2),
    MapEntry('Z', 2),
    MapEntry('Ş', 2),
    MapEntry('C', 2),
    MapEntry('P', 2),
    MapEntry('Ö', 1),
    MapEntry('F', 1),
    MapEntry('Ğ', 1),
    MapEntry('J', 1),
  ];

  static int getScore(String letter) => scores[letter.toUpperCase()] ?? 1;

  static int calculateWordScore(String word) {
    int total = 0;
    for (int i = 0; i < word.length; i++) {
      total += getScore(word[i]);
    }
    return total;
  }

  // Türkçe büyük harf dönüşümü (i → İ sorunu için)
  static String toUpperCaseTR(String s) {
    return s
        .replaceAll('i', 'İ')
        .replaceAll('ı', 'I')
        .toUpperCase();
  }
}

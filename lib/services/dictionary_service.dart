import 'package:flutter/services.dart';

class DictionaryService {
  static DictionaryService? _instance;
  static DictionaryService get instance => _instance!;

  late Set<String> _words;
  late Set<String> _prefixes;

  static Future<DictionaryService> load() async {
    final service = DictionaryService._();
    final content = await rootBundle.loadString('assets/words/turkish_words.txt');
    service._words = content
        .split('\n')
        .map((w) => w.trim().toUpperCase())
        .where((w) => w.length >= 3)
        .toSet();

    service._prefixes = {};
    for (final word in service._words) {
      for (int i = 1; i <= word.length; i++) {
        service._prefixes.add(word.substring(0, i));
      }
    }

    _instance = service;
    return service;
  }

  DictionaryService._();

  bool isValidWord(String word) => _words.contains(word.toUpperCase());
  bool isValidPrefix(String prefix) => _prefixes.contains(prefix.toUpperCase());

  Set<String> get allWords => _words;

  /// Grid üzerinde geçerli kelimeleri hücre yollarıyla birlikte bulur.
  /// Her kelime kendi içinde aynı hücreyi kullanmaz.
  List<_WordPath> _findWordPaths(List<List<String>> grid, int size) {
    final results = <_WordPath>[];
    final seen = <String>{};
    final visited = List.generate(size, (_) => List.filled(size, false));

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        _dfs(grid, r, c, size, '', [], visited, results, seen);
      }
    }
    return results;
  }

  void _dfs(
    List<List<String>> grid,
    int row,
    int col,
    int size,
    String current,
    List<List<int>> path,
    List<List<bool>> visited,
    List<_WordPath> results,
    Set<String> seen,
  ) {
    if (row < 0 || row >= size || col < 0 || col >= size) return;
    if (visited[row][col]) return;

    final newWord = current + grid[row][col];
    if (!isValidPrefix(newWord)) return;

    visited[row][col] = true;
    final newPath = [...path, [row, col]];

    if (newWord.length >= 3 && isValidWord(newWord) && !seen.contains(newWord)) {
      seen.add(newWord);
      results.add(_WordPath(newWord, newPath));
    }

    // Maksimum 10 harf derinliği
    if (newWord.length < 10) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          _dfs(grid, row + dr, col + dc, size, newWord, newPath, visited, results, seen);
        }
      }
    }

    visited[row][col] = false;
  }

  int countNonOverlappingWords(List<List<String>> grid, int size) {
    return getNonOverlappingWords(grid, size).length;
  }

  /// Kural 8: Ortak hücre KULLANAMAYAN kelimelerin listesini döndürür (greedy, uzunluğa göre öncelikli).
  List<String> getNonOverlappingWords(List<List<String>> grid, int size) {
    final wordPaths = _findWordPaths(grid, size);
    if (wordPaths.isEmpty) return [];

    // Uzun kelimeler önce (daha değerli), aynı uzunlukta olan varsa alfabetik
    wordPaths.sort((a, b) {
      final lenCmp = b.word.length.compareTo(a.word.length);
      return lenCmp != 0 ? lenCmp : a.word.compareTo(b.word);
    });

    final usedCells = <String>{};
    final List<String> words = [];

    for (final wp in wordPaths) {
      final cellKeys = wp.path.map((p) => '${p[0]},${p[1]}').toSet();
      if (cellKeys.intersection(usedCells).isEmpty) {
        usedCells.addAll(cellKeys);
        words.add(wp.word);
      }
    }
    return words;
  }

  /// Sadece en az 1 kelime var mı kontrol eder (hızlı versiyon)
  bool hasAtLeastOneWord(List<List<String>> grid, int size) {
    final visited = List.generate(size, (_) => List.filled(size, false));
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (_dfsHasWord(grid, r, c, size, '', visited)) return true;
      }
    }
    return false;
  }

  bool _dfsHasWord(
    List<List<String>> grid,
    int row,
    int col,
    int size,
    String current,
    List<List<bool>> visited,
  ) {
    if (row < 0 || row >= size || col < 0 || col >= size) return false;
    if (visited[row][col]) return false;

    final newWord = current + grid[row][col];
    if (!isValidPrefix(newWord)) return false;

    visited[row][col] = true;

    if (newWord.length >= 3 && isValidWord(newWord)) {
      visited[row][col] = false;
      return true;
    }

    if (newWord.length < 10) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          if (_dfsHasWord(grid, row + dr, col + dc, size, newWord, visited)) {
            visited[row][col] = false;
            return true;
          }
        }
      }
    }

    visited[row][col] = false;
    return false;
  }

  /// Kelime içindeki combo alt kelimeleri bulur
  List<String> findSubWords(String word) {
    final result = <String>[];
    final upper = word.toUpperCase();
    for (int start = 0; start < upper.length; start++) {
      for (int end = start + 3; end <= upper.length; end++) {
        final sub = upper.substring(start, end);
        if (isValidWord(sub) && sub != upper && !result.contains(sub)) {
          result.add(sub);
        }
      }
    }
    return result;
  }
}

class _WordPath {
  final String word;
  final List<List<int>> path;
  _WordPath(this.word, this.path);
}

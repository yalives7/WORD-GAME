import 'dart:math';
import '../models/cell_model.dart';
import '../utils/letter_data.dart';
import 'dictionary_service.dart';

class GridGenerator {
  static final Random _rng = Random();

  // Frekans tablosundan ağırlıklı rastgele harf seç
  static String _randomLetter() {
    int total = 0;
    for (final e in LetterData.frequencies) {
      total += e.value;
    }
    int pick = _rng.nextInt(total);
    for (final e in LetterData.frequencies) {
      pick -= e.value;
      if (pick < 0) return e.key;
    }
    return 'A';
  }

  /// Geçerli en az 1 kelime içeren bir grid üretir.
  static List<List<CellModel>> generate(int size) {
    const maxAttempts = 20;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final grid = _buildGrid(size);
      final letterGrid = _toLetterGrid(grid, size);
      if (DictionaryService.instance.hasAtLeastOneWord(letterGrid, size)) return grid;
    }
    // Son çare: gridi zorla kelime içerecek şekilde üret
    return _generateWithForcedWord(size);
  }

  static List<List<CellModel>> _buildGrid(int size) {
    return List.generate(
      size,
      (r) => List.generate(
        size,
        (c) => CellModel(row: r, col: c, letter: _randomLetter()),
      ),
    );
  }

  static List<List<String>> _toLetterGrid(List<List<CellModel>> grid, int size) {
    return List.generate(size, (r) => List.generate(size, (c) => grid[r][c].letter));
  }

  static List<List<CellModel>> _generateWithForcedWord(int size) {
    final grid = _buildGrid(size);
    final words = DictionaryService.instance.allWords.toList();
    words.shuffle(_rng);

    for (final word in words) {
      if (word.length > size * 2) continue;
      if (_tryPlaceWord(grid, word, size)) break;
    }
    return grid;
  }

  static bool _tryPlaceWord(List<List<CellModel>> grid, String word, int size) {
    final startRow = _rng.nextInt(size);
    final startCol = _rng.nextInt(size);

    // 8 yön dene
    final directions = [
      [0, 1], [0, -1], [1, 0], [-1, 0],
      [1, 1], [1, -1], [-1, 1], [-1, -1],
    ];
    directions.shuffle(_rng);

    for (final dir in directions) {
      int r = startRow, c = startCol;
      bool fits = true;
      final positions = <List<int>>[];

      for (int i = 0; i < word.length; i++) {
        if (r < 0 || r >= size || c < 0 || c >= size) {
          fits = false;
          break;
        }
        positions.add([r, c]);
        r += dir[0];
        c += dir[1];
      }

      if (fits && positions.length == word.length) {
        for (int i = 0; i < word.length; i++) {
          final pos = positions[i];
          grid[pos[0]][pos[1]].letter = word[i];
        }
        return true;
      }
    }
    return false;
  }

  /// Üstten düşen yeni harfler oluşturur (patlatma sonrası)
  static String generateNewLetter() => _randomLetter();

  /// Yerçekimi uygula: boş hücreler varsa üsttekiler aşağı düşer,
  /// boş kalan üst hücreler yeni harflerle dolar.
  static List<List<CellModel>> applyGravity(List<List<CellModel>> grid, int size) {
    final result = List.generate(
      size,
      (r) => List.generate(size, (c) => grid[r][c].copyWith()),
    );

    for (int c = 0; c < size; c++) {
      // Sütundaki mevcut hücreleri (boş olmayanları) al (aşağıdan yukarıya)
      final activeCells = <CellModel>[];

      for (int r = size - 1; r >= 0; r--) {
        if (!result[r][c].isEmpty) {
          activeCells.add(result[r][c]);
        }
      }

      // Aşağıdan doldur, üstteki boşluklar yeni harf alır
      for (int r = size - 1; r >= 0; r--) {
        final idx = size - 1 - r;
        if (idx < activeCells.length) {
          final oldCell = activeCells[idx];
          result[r][c] = oldCell.copyWith(row: r, col: c);
        } else {
          result[r][c] = CellModel(
            row: r,
            col: c,
            letter: generateNewLetter(),
          );
        }
      }
    }

    return result;
  }
}

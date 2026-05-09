import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/cell_model.dart';
import '../models/game_result.dart';
import '../models/joker_model.dart';
import '../services/dictionary_service.dart';
import '../services/grid_generator.dart';
import '../services/storage_service.dart';
import '../utils/letter_data.dart';
import 'dart:async';

class WordResult {
  final bool isValid;
  final String word;
  final int score;
  final List<String> combos;
  final int comboScore;

  WordResult({
    required this.isValid,
    required this.word,
    required this.score,
    this.combos = const [],
    this.comboScore = 0,
  });

  int get totalScore => score + comboScore;
}

class GameProvider extends ChangeNotifier {
  List<List<CellModel>> _grid = [];
  int gridSize = 6;
  int score = 0;
  int movesLeft = 20;
  int totalMoves = 20;
  List<String> foundWords = [];
  String longestWord = '';
  List<String> availableWords = [];
  int availableWordCount = 0;
  DateTime? startTime;
  bool gameOver = false;
  bool isManuallyExiting = false;
  int gameNumber = 1;
  String _username = '';

  // Seçim durumu
  List<List<int>> selectedPath = []; // [[row, col], ...]
  String currentWord = '';

  // Son hamle sonucu
  WordResult? lastResult;
  bool showResult = false;

  // Joker durumu
  JokerType? activeJoker;
  JokerType? animatingJoker;
  List<int>? firstSwapCell; // freeSwap için ilk seçilen hücre

  List<List<CellModel>> get grid => _grid;

  bool get isPathEmpty => selectedPath.isEmpty;

  Timer? _tapTimer;
  bool _isProcessing = false;
  Completer<void>? _animCompleter;

  Future<void> startGame(int size, int moves, String username) async {
    _username = username;
    gridSize = size;
    totalMoves = moves;
    movesLeft = moves;
    score = 0;
    foundWords = [];
    longestWord = '';
    selectedPath = [];
    currentWord = '';
    lastResult = null;
    showResult = false;
    gameOver = false;
    isManuallyExiting = false;
    activeJoker = null;
    animatingJoker = null;
    firstSwapCell = null;
    startTime = DateTime.now();
    gameNumber = 0; // _saveResult sırasında otomatik atanır

    _grid = GridGenerator.generate(size);
    _updateAvailableWords();
    notifyListeners();
  }

  void _updateAvailableWords() {
    final letterGrid = _toLetterGrid();
    final dict = DictionaryService.instance;

    // Kural 8: çakışmayan (ortak hücre kullanmayan) kelimeleri ve sayısını al
    availableWords = dict.getNonOverlappingWords(letterGrid, gridSize);
    availableWordCount = availableWords.length;

    // Kural 7: hiç kelime kalmadıysa otomatik yeniden üret
    if (availableWordCount == 0 && !gameOver) {
      _grid = GridGenerator.generate(gridSize);
      final newGrid = _toLetterGrid();
      availableWords = dict.getNonOverlappingWords(newGrid, gridSize);
      availableWordCount = availableWords.length;
    }
  }

  List<List<String>> _toLetterGrid() {
    return List.generate(
      gridSize,
      (r) => List.generate(gridSize, (c) => _grid[r][c].letter),
    );
  }

  // --- Hücre seçim mantığı ---

  void onCellTap(int row, int col) {
    if (gameOver || _isProcessing) return;
    if (activeJoker != null) {
      _handleJokerTap(row, col);
      return;
    }
    
    // Zaten seçilmiş mi kontrol et
    for (final p in selectedPath) {
      if (p[0] == row && p[1] == col) return;
    }

    if (selectedPath.isEmpty) {
      _selectCell(row, col);
      _startTapTimer();
    } else {
      final last = selectedPath.last;
      // Sadece komşu hücre ise ekle
      if ((row - last[0]).abs() <= 1 && (col - last[1]).abs() <= 1) {
        _selectCell(row, col);
        _startTapTimer();
      } else {
        // Komşu değilse mevcut seçimi temizle ve yeni harften başla
        _clearSelection();
        _selectCell(row, col);
        _startTapTimer();
      }
    }
  }

  void _startTapTimer() {
    _tapTimer?.cancel();
    _tapTimer = Timer(const Duration(milliseconds: 1200), () {
      if (currentWord.length >= 3) {
        final word = currentWord.toUpperCase();
        if (DictionaryService.instance.isValidWord(word)) {
          _validateAndSubmit();
          return;
        }
      }
      // Geçerli bir kelime oluşmadıysa seçimi iptal et
      _clearSelection();
    });
  }

  void onPanStart(int row, int col) {
    _tapTimer?.cancel();
    if (gameOver || _isProcessing) return;
    if (activeJoker != null) {
      _handleJokerTap(row, col);
      return;
    }
    _clearSelection();
    _selectCell(row, col);
  }

  void onPanUpdate(int row, int col) {
    if (gameOver || _isProcessing || activeJoker != null) return;
    if (selectedPath.isEmpty) {
      _selectCell(row, col);
      return;
    }
    final last = selectedPath.last;
    // Zaten seçilmiş mi?
    for (final p in selectedPath) {
      if (p[0] == row && p[1] == col) return;
    }
    // Komşu mu?
    if ((row - last[0]).abs() <= 1 && (col - last[1]).abs() <= 1) {
      _selectCell(row, col);
    }
  }

  void onPanEnd() {
    _tapTimer?.cancel();
    if (gameOver || _isProcessing || activeJoker != null) return;
    if (currentWord.length >= 3) {
      _validateAndSubmit();
    } else {
      _clearSelection();
    }
  }

  void _selectCell(int row, int col) {
    selectedPath.add([row, col]);
    currentWord += _grid[row][col].letter;
    _grid[row][col] = _grid[row][col].copyWith(isSelected: true);
    notifyListeners();
  }

  void _clearSelection() {
    for (final p in selectedPath) {
      _grid[p[0]][p[1]] = _grid[p[0]][p[1]].copyWith(isSelected: false);
    }
    selectedPath = [];
    currentWord = '';
    notifyListeners();
  }

  Future<void> _validateAndSubmit() async {
    if (gameOver || movesLeft <= 0 || _isProcessing) return;
    _isProcessing = true;
    movesLeft--;
    final word = currentWord.toUpperCase();
    final dict = DictionaryService.instance;

    if (!dict.isValidWord(word)) {
      lastResult = WordResult(isValid: false, word: word, score: 0);
      showResult = true;
      _clearSelection();
      if (movesLeft <= 0) {
        gameOver = true;
        _saveResult();
      }
      notifyListeners();
      _hideResultAfterDelay();
      _isProcessing = false;
      return;
    }

    // Kelime puanı
    int wordScore = LetterData.calculateWordScore(word);

    // Combo hesapla
    final subWords = dict.findSubWords(word);
    int comboScore = 0;
    for (final sub in subWords) {
      comboScore += LetterData.calculateWordScore(sub);
    }

    // Özel güç belirle
    SpecialPower? power;
    if (word.length == 4) {
      power = SpecialPower.rowClear;
    } else if (word.length == 5) {
      power = SpecialPower.areaBomb;
    } else if (word.length == 6) {
      power = SpecialPower.columnClear;
    } else if (word.length >= 7) {
      power = SpecialPower.megaBomb;
    }

    // Son hücrenin konumu ve orijinal harfi (temizlemeden önce sakla)
    final lastCell = selectedPath.last;
    final lastCellLetter = _grid[lastCell[0]][lastCell[1]].letter;

    // Seçili hücreleri temizle (özel güçleri kontrol et ve uygula)
    final cellsToRemove = <List<int>>[...selectedPath];
    final activatedPowers = <_PowerActivation>[];

    for (final p in selectedPath) {
      final cell = _grid[p[0]][p[1]];
      if (cell.specialPower != null) {
        activatedPowers.add(_PowerActivation(cell.specialPower!, p[0], p[1]));
      }
    }

    // Hücreleri patlat - animated (yeni obje oluştur)
    for (final p in cellsToRemove) {
      final cell = _grid[p[0]][p[1]];
      _grid[p[0]][p[1]] = cell.copyWith(isDestroyed: true);
    }
    notifyListeners(); // Animasyon başlasın

    // Animasyon tamamlanana kadar bekle (400ms - yeni hızlı patlama)
    await Future.delayed(const Duration(milliseconds: 400));

    // Hücreleri boşalt
    for (final p in cellsToRemove) {
      final cell = _grid[p[0]][p[1]];
      _grid[p[0]][p[1]] = cell.copyWith(letter: '', isEmpty: true);
    }

    // Aktif güçleri uygula
    for (final activation in activatedPowers) {
      _applyPower(activation.power, activation.row, activation.col);
    }

    // Activated güçlerin destroy işareti varsa, animasyonu görmek için bekle
    if (activatedPowers.isNotEmpty) {
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 400));
    }

    // Destroyed işaretli tüm hücreleri temizle
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (_grid[r][c].isDestroyed) {
          _grid[r][c] = _grid[r][c].copyWith(letter: '', isEmpty: true);
        }
      }
    }

    // Yerçekimi uygula (sembol yerleştirmeden önce — sembol orijinal konumunda kalsın)
    _grid = GridGenerator.applyGravity(_grid, gridSize);

    // Son hücreye özel güç sembolü yerleştir: yerçekiminden sonra orijinal konuma yazar
    if (power != null) {
      _grid[lastCell[0]][lastCell[1]] = _grid[lastCell[0]][lastCell[1]].copyWith(
        letter: lastCellLetter,
        specialPower: power,
        clearSpecialPower: false,
      );
    }

    // Puan ekle
    score += wordScore + comboScore;

    // Kelime listesi güncelle
    if (!foundWords.contains(word)) foundWords.add(word);
    if (word.length > longestWord.length) longestWord = word;

    lastResult = WordResult(
      isValid: true,
      word: word,
      score: wordScore,
      combos: subWords,
      comboScore: comboScore,
    );
    showResult = true;
    selectedPath = [];
    currentWord = '';

    _updateAvailableWords();

    if (movesLeft <= 0) {
      gameOver = true;
      _saveResult();
    }

    _isProcessing = false;
    notifyListeners();
    _hideResultAfterDelay();
  }

  void _applyPower(SpecialPower power, int row, int col) {
    switch (power) {
      case SpecialPower.rowClear:
        for (int c = 0; c < gridSize; c++) {
          final cell = _grid[row][c];
          _grid[row][c] = cell.copyWith(isDestroyed: true);
        }
      case SpecialPower.columnClear:
        for (int r = 0; r < gridSize; r++) {
          final cell = _grid[r][col];
          _grid[r][col] = cell.copyWith(isDestroyed: true);
        }
      case SpecialPower.areaBomb:
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            final nr = row + dr;
            final nc = col + dc;
            if (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
              final cell = _grid[nr][nc];
              _grid[nr][nc] = cell.copyWith(isDestroyed: true);
            }
          }
        }
      case SpecialPower.megaBomb:
        for (int dr = -2; dr <= 2; dr++) {
          for (int dc = -2; dc <= 2; dc++) {
            final nr = row + dr;
            final nc = col + dc;
            if (nr >= 0 && nr < gridSize && nc >= 0 && nc < gridSize) {
              final cell = _grid[nr][nc];
              _grid[nr][nc] = cell.copyWith(isDestroyed: true);
            }
          }
        }
    }
  }

  void _hideResultAfterDelay() {
    Future.delayed(const Duration(seconds: 2), () {
      showResult = false;
      notifyListeners();
    });
  }

  // --- Joker Mekaniği ---

  // Joker kullanıldığında çağrılacak callback (sayacı düşürür)
  Function(JokerType)? _onJokerUsed;

  /// Anında uygulanan jokerler: fish, shuffle, partyBooster
  /// Hücre seçimi gerektiren jokerler: lollipop, wheel, freeSwap
  Future<void> activateJoker(JokerType type, {required Function(JokerType) onUsed}) async {
    if (_isProcessing) return;
    _isProcessing = true;
    _clearSelection();
    _onJokerUsed = onUsed;

    // Animasyon başlat
    animatingJoker = type;
    _animCompleter = Completer<void>();
    notifyListeners();

    // Animasyon süresi kadar bekle (veya atla)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_animCompleter != null && !_animCompleter!.isCompleted) {
        _animCompleter!.complete();
      }
    });

    await _animCompleter!.future;
    _animCompleter = null;

    switch (type) {
      case JokerType.fish:
      case JokerType.shuffle:
      case JokerType.partyBooster:
        // Anında uygula
        switch (type) {
          case JokerType.fish:
            _applyFishJoker();
          case JokerType.shuffle:
            _applyShuffleJoker();
          case JokerType.partyBooster:
            _applyPartyBooster();
          default:
            break;
        }
        onUsed(type);
        _onJokerUsed = null;
        activeJoker = null;
        animatingJoker = null;
        _isProcessing = false;
        notifyListeners();

      case JokerType.lollipop:
      case JokerType.wheel:
      case JokerType.freeSwap:
        // Hücre seçimi bekleniyor
        if (activeJoker == type) {
          activeJoker = null;
          _onJokerUsed = null;
        } else {
          activeJoker = type;
          firstSwapCell = null;
        }
        animatingJoker = null;
        _isProcessing = false;
        notifyListeners();
    }
  }

  void skipJokerAnimation() {
    if (_animCompleter != null && !_animCompleter!.isCompleted) {
      _animCompleter!.complete();
    }
  }

  void cancelJoker() {
    activeJoker = null;
    
    if (firstSwapCell != null) {
      _grid[firstSwapCell![0]][firstSwapCell![1]] = 
          _grid[firstSwapCell![0]][firstSwapCell![1]].copyWith(isSelected: false);
    }
    firstSwapCell = null;
    _onJokerUsed = null;
    notifyListeners();
  }

  Future<void> _handleJokerTap(int row, int col) async {
    if (_isProcessing) return;
    _isProcessing = true;
    
    switch (activeJoker) {
      case JokerType.lollipop:
        final cell = _grid[row][col];
        _grid[row][col] = cell.copyWith(isDestroyed: true);
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 400));
        _grid[row][col] = cell.copyWith(letter: '', isEmpty: true);
        _grid = GridGenerator.applyGravity(_grid, gridSize);
        _updateAvailableWords();
        _onJokerUsed?.call(JokerType.lollipop);
        _onJokerUsed = null;
        activeJoker = null;
        _isProcessing = false;
        notifyListeners();

      case JokerType.wheel:
        // Satır hücrelerini işaretle
        for (int c = 0; c < gridSize; c++) {
          final cell = _grid[row][c];
          _grid[row][c] = cell.copyWith(isDestroyed: true);
        }
        // Sütun hücrelerini işaretle
        for (int r = 0; r < gridSize; r++) {
          final cell = _grid[r][col];
          _grid[r][col] = cell.copyWith(isDestroyed: true);
        }
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 400));

        // Şimdi temizle
        for (int c = 0; c < gridSize; c++) {
          _grid[row][c] = _grid[row][c].copyWith(letter: '', isEmpty: true);
        }
        for (int r = 0; r < gridSize; r++) {
          _grid[r][col] = _grid[r][col].copyWith(letter: '', isEmpty: true);
        }
        _grid = GridGenerator.applyGravity(_grid, gridSize);
        _updateAvailableWords();
        _onJokerUsed?.call(JokerType.wheel);
        _onJokerUsed = null;
        activeJoker = null;
        _isProcessing = false;
        notifyListeners();

      case JokerType.freeSwap:
        if (firstSwapCell == null) {
          firstSwapCell = [row, col];
          _grid[row][col] = _grid[row][col].copyWith(isSelected: true);
          _isProcessing = false;
          notifyListeners();
        } else {
          final fr = firstSwapCell![0];
          final fc = firstSwapCell![1];
          if ((row - fr).abs() <= 1 && (col - fc).abs() <= 1) {
            final cell1 = _grid[fr][fc];
            final cell2 = _grid[row][col];
            _grid[fr][fc] = cell2.copyWith(isSelected: false);
            _grid[row][col] = cell1.copyWith(isSelected: false);
            _updateAvailableWords();
            _onJokerUsed?.call(JokerType.freeSwap);
            _onJokerUsed = null;
          }
          _grid[fr][fc] = _grid[fr][fc].copyWith(isSelected: false);
          firstSwapCell = null;
          activeJoker = null;
          _isProcessing = false;
          notifyListeners();
        }

      default:
        _isProcessing = false;
        break;
    }
  }

  void _applyFishJoker() {
    final rng = Random();
    final count = gridSize ~/ 2;
    final positions = <List<int>>[];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        positions.add([r, c]);
      }
    }
    positions.shuffle(rng);
    for (int i = 0; i < count && i < positions.length; i++) {
      final p = positions[i];
      final cell = _grid[p[0]][p[1]];
      _grid[p[0]][p[1]] = cell.copyWith(isDestroyed: true);
    }
    notifyListeners();
    // Animasyon bittikten sonra temizle
    Future.delayed(const Duration(milliseconds: 400), () {
      for (int i = 0; i < count && i < positions.length; i++) {
        final p = positions[i];
        _grid[p[0]][p[1]] = _grid[p[0]][p[1]].copyWith(letter: '', isEmpty: true);
      }
      _grid = GridGenerator.applyGravity(_grid, gridSize);
      _updateAvailableWords();
      activeJoker = null;
      notifyListeners();
    });
  }

  void _applyShuffleJoker() {
    final allCells = <CellModel>[];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        allCells.add(_grid[r][c]);
      }
    }
    allCells.shuffle();
    int idx = 0;
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        _grid[r][c] = allCells[idx];
        idx++;
      }
    }
    _updateAvailableWords();
    activeJoker = null;
    notifyListeners();
  }

  void _applyPartyBooster() {
    _grid = GridGenerator.generate(gridSize);
    _updateAvailableWords();
    activeJoker = null;
    notifyListeners();
  }

  Future<void> _saveResult() async {
    final duration =
        startTime != null ? DateTime.now().difference(startTime!).inSeconds : 0;
    // Kayıtlı oyun sayısına göre sıralı numara ver
    final existingResults = await StorageService.loadResults(_username);
    final newGameNumber = existingResults.length + 1;
    final result = GameResult(
      gameNumber: newGameNumber,
      date: DateTime.now(),
      gridSize: gridSize,
      score: score,
      wordCount: foundWords.length,
      longestWord: longestWord,
      durationSeconds: duration,
    );
    await StorageService.saveResult(_username, result);
  }

  Future<void> endGameEarly() async {
    isManuallyExiting = true;
    gameOver = true;
    await _saveResult();
    notifyListeners();
  }
}

class _PowerActivation {
  final SpecialPower power;
  final int row;
  final int col;
  _PowerActivation(this.power, this.row, this.col);
}

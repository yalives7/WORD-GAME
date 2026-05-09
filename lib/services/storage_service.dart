import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_result.dart';
import '../models/player_data.dart';

class StorageService {
  static const _currentUserKey = 'current_user';
  static const _allUsersKey = 'all_users';
  static const _dataVersionKey = 'data_version';
  static const _currentDataVersion = 3; // jokerler 0'dan başlar

  static String _playerKey(String username) => 'player_$username';
  static String _resultsKey(String username) => 'results_$username';
  static String _gameCountKey(String username) => 'game_count_$username';

  /// Uygulama başlarken çağrılır — eski veri varsa joker sayılarını sıfırlar
  static Future<void> migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final version = prefs.getInt(_dataVersionKey) ?? 0;
    if (version < _currentDataVersion) {
      // Tüm kullanıcıların joker sayılarını sıfırla
      final users = prefs.getStringList(_allUsersKey) ?? [];
      for (final username in users) {
        final raw = prefs.getString('player_$username');
        if (raw != null) {
          final data = PlayerData.fromJson(
              jsonDecode(raw) as Map<String, dynamic>);
          // Joker sayılarını sıfırla (altın ve diğer veriler korunur)
          for (final type in data.jokerCounts.keys.toList()) {
            data.jokerCounts[type] = 0;
          }
          await prefs.setString('player_$username', jsonEncode(data.toJson()));
        }
      }
      await prefs.setInt(_dataVersionKey, _currentDataVersion);
    }
  }

  // --- Kullanıcı yönetimi ---

  static Future<String?> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  static Future<void> setCurrentUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, username);
  }

  static Future<List<String>> getAllUsernames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_allUsersKey) ?? [];
  }

  static Future<void> addUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_allUsersKey) ?? [];
    if (!users.contains(username)) {
      users.add(username);
      await prefs.setStringList(_allUsersKey, users);
    }
  }

  static Future<void> removeUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_allUsersKey) ?? [];
    users.remove(username);
    await prefs.setStringList(_allUsersKey, users);
    await prefs.remove(_playerKey(username));
    await prefs.remove(_resultsKey(username));
    await prefs.remove(_gameCountKey(username));
  }

  static Future<void> renameUsername(String oldUsername, String newUsername) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_allUsersKey) ?? [];
    
    users.remove(oldUsername);
    if (!users.contains(newUsername)) {
      users.add(newUsername);
    }
    await prefs.setStringList(_allUsersKey, users);

    final playerRaw = prefs.getString(_playerKey(oldUsername));
    if (playerRaw != null) {
      final Map<String, dynamic> playerMap = jsonDecode(playerRaw);
      playerMap['username'] = newUsername;
      await prefs.setString(_playerKey(newUsername), jsonEncode(playerMap));
      await prefs.remove(_playerKey(oldUsername));
    }

    final results = prefs.getStringList(_resultsKey(oldUsername));
    if (results != null) {
      await prefs.setStringList(_resultsKey(newUsername), results);
      await prefs.remove(_resultsKey(oldUsername));
    }

    final gameCount = prefs.getInt(_gameCountKey(oldUsername));
    if (gameCount != null) {
      await prefs.setInt(_gameCountKey(newUsername), gameCount);
      await prefs.remove(_gameCountKey(oldUsername));
    }
  }

  // --- Oyuncu verisi ---

  static Future<PlayerData> loadPlayerData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_playerKey(username));
    if (raw == null) return PlayerData(username: username);
    return PlayerData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  static Future<void> savePlayerData(String username, PlayerData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playerKey(username), jsonEncode(data.toJson()));
  }

  // --- Oyun sonuçları ---

  static Future<List<GameResult>> loadResults(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_resultsKey(username)) ?? [];
    return raw
        .map((s) => GameResult.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static Future<void> saveResult(String username, GameResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final results = await loadResults(username);
    results.add(result);
    await prefs.setStringList(
      _resultsKey(username),
      results.map((r) => jsonEncode(r.toJson())).toList(),
    );
  }

  static Future<int> nextGameNumber(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final n = (prefs.getInt(_gameCountKey(username)) ?? 0) + 1;
    await prefs.setInt(_gameCountKey(username), n);
    return n;
  }
}

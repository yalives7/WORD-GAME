import 'package:flutter/foundation.dart';
import '../models/player_data.dart';
import '../models/joker_model.dart';
import '../services/storage_service.dart';

class PlayerProvider extends ChangeNotifier {
  PlayerData _data = PlayerData(username: '');
  List<String> _allUsers = [];

  String get username => _data.username;
  int get gold => _data.gold;
  Map<JokerType, int> get jokerCounts => _data.jokerCounts;
  int get totalGamesPlayed => _data.totalGamesPlayed;
  List<String> get allUsers => _allUsers;

  int jokerCount(JokerType type) => _data.jokerCounts[type] ?? 0;

  /// İlk açılışta mevcut kullanıcıyı yükle
  Future<String?> loadCurrentUser() async {
    _allUsers = await StorageService.getAllUsernames();
    final currentUsername = await StorageService.getCurrentUsername();
    if (currentUsername != null && currentUsername.isNotEmpty) {
      _data = await StorageService.loadPlayerData(currentUsername);
      notifyListeners();
      return currentUsername;
    }
    return null;
  }

  /// Yeni kullanıcı oluştur
  Future<void> createUser(String username) async {
    _data = PlayerData(username: username);
    await StorageService.addUsername(username);
    await StorageService.setCurrentUsername(username);
    await StorageService.savePlayerData(username, _data);
    _allUsers = await StorageService.getAllUsernames();
    notifyListeners();
  }

  /// Kullanıcı adını güncelle
  Future<void> updateUsername(String newUsername) async {
    final oldUsername = _data.username;
    _data.username = newUsername;
    // Eski kaydı sil, yeni isimle kaydet
    await StorageService.renameUsername(oldUsername, newUsername);
    await StorageService.setCurrentUsername(newUsername);
    await StorageService.savePlayerData(newUsername, _data);
    _allUsers = await StorageService.getAllUsernames();
    notifyListeners();
  }

  /// Başka bir kullanıcıya geç
  Future<void> switchUser(String username) async {
    await StorageService.setCurrentUsername(username);
    _data = await StorageService.loadPlayerData(username);
    notifyListeners();
  }

  Future<void> buyJoker(JokerType type, int cost) async {
    if (_data.gold < cost) return;
    _data.gold -= cost;
    _data.jokerCounts[type] = (_data.jokerCounts[type] ?? 0) + 1;
    await StorageService.savePlayerData(_data.username, _data);
    notifyListeners();
  }

  Future<void> useJoker(JokerType type) async {
    final count = _data.jokerCounts[type] ?? 0;
    if (count <= 0) return;
    _data.jokerCounts[type] = count - 1;
    await StorageService.savePlayerData(_data.username, _data);
    notifyListeners();
  }

  Future<void> incrementGames() async {
    _data.totalGamesPlayed++;
    await StorageService.savePlayerData(_data.username, _data);
    notifyListeners();
  }
}

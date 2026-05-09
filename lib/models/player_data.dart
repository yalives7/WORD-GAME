import 'joker_model.dart';

class PlayerData {
  String username;
  int gold;
  Map<JokerType, int> jokerCounts;
  int totalGamesPlayed;

  PlayerData({
    required this.username,
    this.gold = 10000,
    Map<JokerType, int>? jokerCounts,
    this.totalGamesPlayed = 0,
  }) : jokerCounts = jokerCounts ?? {
          JokerType.fish: 0,
          JokerType.wheel: 0,
          JokerType.lollipop: 0,
          JokerType.freeSwap: 0,
          JokerType.shuffle: 0,
          JokerType.partyBooster: 0,
        };

  Map<String, dynamic> toJson() => {
        'username': username,
        'gold': gold,
        'jokerCounts': jokerCounts.map((k, v) => MapEntry(k.index.toString(), v)),
        'totalGamesPlayed': totalGamesPlayed,
      };

  factory PlayerData.fromJson(Map<String, dynamic> json) {
    final countsJson = (json['jokerCounts'] as Map<String, dynamic>?) ?? {};
    final counts = <JokerType, int>{};
    for (final type in JokerType.values) {
      counts[type] = (countsJson[type.index.toString()] as int?) ?? 0;
    }
    return PlayerData(
      username: (json['username'] as String?) ?? '',
      gold: (json['gold'] as int?) ?? 10000,
      jokerCounts: counts,
      totalGamesPlayed: (json['totalGamesPlayed'] as int?) ?? 0,
    );
  }
}

class GameResult {
  final int gameNumber;
  final DateTime date;
  final int gridSize;
  final int score;
  final int wordCount;
  final String longestWord;
  final int durationSeconds;

  GameResult({
    required this.gameNumber,
    required this.date,
    required this.gridSize,
    required this.score,
    required this.wordCount,
    required this.longestWord,
    required this.durationSeconds,
  });

  Map<String, dynamic> toJson() => {
    'gameNumber': gameNumber,
    'date': date.toIso8601String(),
    'gridSize': gridSize,
    'score': score,
    'wordCount': wordCount,
    'longestWord': longestWord,
    'durationSeconds': durationSeconds,
  };

  factory GameResult.fromJson(Map<String, dynamic> json) => GameResult(
    gameNumber: json['gameNumber'] as int,
    date: DateTime.parse(json['date'] as String),
    gridSize: json['gridSize'] as int,
    score: json['score'] as int,
    wordCount: json['wordCount'] as int,
    longestWord: json['longestWord'] as String,
    durationSeconds: json['durationSeconds'] as int,
  );
}

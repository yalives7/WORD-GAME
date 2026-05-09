enum JokerType { fish, wheel, lollipop, freeSwap, shuffle, partyBooster }

class JokerModel {
  final JokerType type;
  final String name;
  final int cost;
  final String description;
  final String icon;

  const JokerModel({
    required this.type,
    required this.name,
    required this.cost,
    required this.description,
    required this.icon,
  });

  static const List<JokerModel> all = [
    JokerModel(
      type: JokerType.fish,
      name: 'Balık',
      cost: 100,
      description: 'Gridde rastgele harfleri yok eder. Üstteki harfler aşağı düşer.',
      icon: '🐟',
    ),
    JokerModel(
      type: JokerType.wheel,
      name: 'Tekerlek',
      cost: 200,
      description: 'Seçilen harfin bulunduğu satır ve sütundaki tüm harfleri yok eder.',
      icon: '⚙️',
    ),
    JokerModel(
      type: JokerType.lollipop,
      name: 'Lolipop Kırıcı',
      cost: 75,
      description: 'Gridde seçilen tek bir harfi yok eder. Üsttekiler aşağı düşer.',
      icon: '🍭',
    ),
    JokerModel(
      type: JokerType.freeSwap,
      name: 'Serbest Değiştirme',
      cost: 125,
      description: 'Birbirine temas eden iki harfin yerini değiştirir.',
      icon: '🔄',
    ),
    JokerModel(
      type: JokerType.shuffle,
      name: 'Harf Karıştırma',
      cost: 300,
      description: 'Gridde bulunan tüm harfleri rastgele karıştırır.',
      icon: '🔀',
    ),
    JokerModel(
      type: JokerType.partyBooster,
      name: 'Parti Güçlendiricisi',
      cost: 400,
      description: 'Tüm harfleri yok eder ve yeniden rastgele üretir.',
      icon: '🎉',
    ),
  ];

  static JokerModel getById(JokerType type) =>
      all.firstWhere((j) => j.type == type);
}

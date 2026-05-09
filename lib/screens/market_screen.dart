import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/joker_model.dart';
import '../providers/player_provider.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  static const Map<JokerType, _JokerTheme> _themes = {
    JokerType.lollipop: _JokerTheme(
      gradient: [Color(0xFFAD1457), Color(0xFF6A1B9A)],
      accent: Color(0xFFEC407A),
      darkAccent: Color(0xFF880E4F),
    ),
    JokerType.wheel: _JokerTheme(
      gradient: [Color(0xFFBF360C), Color(0xFF4E342E)],
      accent: Color(0xFFFF7043),
      darkAccent: Color(0xFFBF360C),
    ),
    JokerType.fish: _JokerTheme(
      gradient: [Color(0xFF006064), Color(0xFF004D40)],
      accent: Color(0xFF26C6DA),
      darkAccent: Color(0xFF00838F),
    ),
    JokerType.freeSwap: _JokerTheme(
      gradient: [Color(0xFF311B92), Color(0xFF1A237E)],
      accent: Color(0xFF7C4DFF),
      darkAccent: Color(0xFF4527A0),
    ),
    JokerType.shuffle: _JokerTheme(
      gradient: [Color(0xFF1B5E20), Color(0xFF004D40)],
      accent: Color(0xFF66BB6A),
      darkAccent: Color(0xFF2E7D32),
    ),
    JokerType.partyBooster: _JokerTheme(
      gradient: [Color(0xFFE65100), Color(0xFF4E342E)],
      accent: Color(0xFFFFCA28),
      darkAccent: Color(0xFFF57F17),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          // Market'ten çıkarken tüm SnackBar'ları kapat
          ScaffoldMessenger.of(context).clearSnackBars();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF080D1A),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 140,
              backgroundColor: const Color(0xFF0D1640),
              foregroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _MarketHeader(gold: player.gold),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.56,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final joker = JokerModel.all[i];
                    final theme = _themes[joker.type]!;
                    final count = player.jokerCount(joker.type);
                    final canAfford = player.gold >= joker.cost;
                    return _JokerCard(
                      joker: joker,
                      theme: theme,
                      count: count,
                      canAfford: canAfford,
                      onBuy: () async {
                        await player.buyJoker(joker.type, joker.cost);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Text(joker.icon,
                                      style: const TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text('${joker.name} satın alındı!'),
                                ],
                              ),
                              backgroundColor: Colors.green.shade800,
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    );
                  },
                  childCount: JokerModel.all.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JokerTheme {
  final List<Color> gradient;
  final Color accent;
  final Color darkAccent;
  const _JokerTheme(
      {required this.gradient, required this.accent, required this.darkAccent});
}

class _MarketHeader extends StatelessWidget {
  final int gold;
  const _MarketHeader({required this.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), Color(0xFF0D1640)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'M A R K E T',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0x20FFD700),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x55FFD700), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
                      ),
                      boxShadow: [
                        BoxShadow(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.4),
                            blurRadius: 8)
                      ],
                    ),
                    child: const Icon(Icons.monetization_on_rounded,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    gold.toString(),
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'altın',
                    style: TextStyle(color: Color(0xAAFFD700), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JokerCard extends StatefulWidget {
  final JokerModel joker;
  final _JokerTheme theme;
  final int count;
  final bool canAfford;
  final VoidCallback onBuy;

  const _JokerCard({
    required this.joker,
    required this.theme,
    required this.count,
    required this.canAfford,
    required this.onBuy,
  });

  @override
  State<_JokerCard> createState() => _JokerCardState();
}

class _JokerCardState extends State<_JokerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.canAfford) return;
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onBuy();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: Stack(
        children: [
          GestureDetector(
            onTap: _handleTap,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: theme.gradient,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.accent.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.accent.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
                child: Column(
                  children: [
                    // Simge
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black26,
                        border: Border.all(
                          color: theme.accent.withValues(alpha: 0.45),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.accent.withValues(alpha: 0.25),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.joker.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // İsim
                    Text(
                      widget.joker.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.joker.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Fiyat
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
                            ),
                          ),
                          child: const Icon(Icons.monetization_on_rounded,
                              color: Colors.white, size: 11),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${widget.joker.cost}',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    // Satın al butonu
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: widget.canAfford
                              ? LinearGradient(
                                  colors: [theme.accent, theme.darkAccent])
                              : null,
                          color: widget.canAfford ? null : Colors.white12,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: widget.canAfford
                              ? [
                                  BoxShadow(
                                    color: theme.accent.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            widget.canAfford ? 'Satın Al' : 'Yetersiz',
                            style: TextStyle(
                              color: widget.canAfford
                                  ? Colors.white
                                  : Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Stok rozeti (sağ üst)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.accent.withValues(alpha: 0.5)),
              ),
              child: Text(
                'x${widget.count}',
                style: TextStyle(
                  color: theme.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

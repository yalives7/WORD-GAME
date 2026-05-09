import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/joker_model.dart';
import '../widgets/game_grid_widget.dart';
import '../widgets/joker_bar_widget.dart';
import '../widgets/how_to_play_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _gameOverDialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gameProvider = context.read<GameProvider>();
    if (gameProvider.gameOver && !gameProvider.isManuallyExiting && !_gameOverDialogShown) {
      _gameOverDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showGameOverDialog(gameProvider);
      });
    }
  }

  Future<bool> _onWillPop(GameProvider gameProvider) async {
    if (gameProvider.gameOver) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D40),
        title: const Text('Oyundan Çık?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Oyundan çıkmak istediğinize emin misiniz?\nSonucunuz kaydedilecektir.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hayır', style: TextStyle(color: Color(0xFF4A90D9))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await gameProvider.endGameEarly();
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Evet'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showGameOverDialog(GameProvider gameProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF1E2D40), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 30,
                spreadRadius: 10,
              )
            ],
          ),
          child: _GameOverContent(
            gameProvider: gameProvider,
            onGoHome: () => Navigator.popUntil(ctx, (route) => route.isFirst),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();

    // Oyun bitti mi kontrol et
    if (gameProvider.gameOver && !gameProvider.isManuallyExiting && !_gameOverDialogShown) {
      _gameOverDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showGameOverDialog(gameProvider);
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop(gameProvider);
        if (shouldPop && context.mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0F1E),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _TopBar(gameProvider: gameProvider),
                  const SizedBox(height: 8),
                  _WordDisplay(gameProvider: gameProvider),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: gameProvider.grid.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : const GameGridWidget(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (gameProvider.activeJoker != null)
                    _ActiveJokerBanner(gameProvider: gameProvider),
                  const JokerBarWidget(),
                ],
              ),
              // Joker Activation Animation Overlay
              if (gameProvider.animatingJoker != null)
                _JokerActivationOverlay(jokerType: gameProvider.animatingJoker!),
            ],
          ),
        ),
      ),
    );
  }
}


class _TopBar extends StatelessWidget {
  final GameProvider gameProvider;
  const _TopBar({required this.gameProvider});

  @override
  Widget build(BuildContext context) {
    final progress = gameProvider.movesLeft / (gameProvider.totalMoves == 0 ? 1 : gameProvider.totalMoves);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: const Color(0xFF0D1B2A),
      child: Column(
        children: [
          Row(
            children: [
              // Geri butonu
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () async {
                  final shouldPop = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1E2D40),
                      title: const Text('Oyundan Çık?', style: TextStyle(color: Colors.white)),
                      content: const Text(
                        'Oyundan çıkmak istiyor musunuz?\nSonucunuz kaydedilecektir.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Hayır'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () async {
                            await gameProvider.endGameEarly();
                            if (ctx.mounted) Navigator.pop(ctx, true);
                          },
                          child: const Text('Evet'),
                        ),
                      ],
                    ),
                  );
                  if ((shouldPop ?? false) && context.mounted) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
              ),
              // Bilgi Butonu
              IconButton(
                icon: const Icon(Icons.tips_and_updates_rounded, color: Color(0xFFFFD700)),
                onPressed: () => HowToPlayDialog.show(context),
                tooltip: 'Nasıl Oynanır?',
              ),
              // Puan
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${gameProvider.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('PUAN', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
              // Hamle
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${gameProvider.movesLeft}',
                    style: TextStyle(
                      color: gameProvider.movesLeft <= 5 ? Colors.red : Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Hamle', style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Hamle progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(
                progress > 0.3 ? const Color(0xFF4CAF50) : Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Oluşturulabilir kelime sayısı
          Text(
            'Gridde Oluşturulabilir Kelime Sayısı: ${gameProvider.availableWordCount}',
            style: const TextStyle(color: Color(0xFF4A90D9), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _WordDisplay extends StatelessWidget {
  final GameProvider gameProvider;
  const _WordDisplay({required this.gameProvider});

  @override
  Widget build(BuildContext context) {
    String displayText = gameProvider.currentWord.isEmpty ? '...' : gameProvider.currentWord;
    Color textColor = Colors.white70;

    if (gameProvider.showResult && gameProvider.lastResult != null) {
      final result = gameProvider.lastResult!;
      if (result.isValid) {
        displayText = '✓ ${result.word}  +${result.totalScore}';
        textColor = const Color(0xFF66BB6A);
      } else {
        displayText = '✗ ${result.word}';
        textColor = Colors.redAccent;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2D40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A4060)),
      ),
      child: Column(
        children: [
          Text(
            displayText,
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          if (gameProvider.showResult &&
              gameProvider.lastResult != null &&
              gameProvider.lastResult!.isValid &&
              gameProvider.lastResult!.combos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Combo: ${gameProvider.lastResult!.combos.join(", ")}  +${gameProvider.lastResult!.comboScore}',
                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActiveJokerBanner extends StatelessWidget {
  final GameProvider gameProvider;
  const _ActiveJokerBanner({required this.gameProvider});

  @override
  Widget build(BuildContext context) {
    final joker = JokerModel.getById(gameProvider.activeJoker!);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD700)),
      ),
      child: Row(
        children: [
          Text(joker.icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${joker.name} aktif — Bir hücreye dokun',
              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: gameProvider.cancelJoker,
            child: const Icon(Icons.close, color: Colors.white54, size: 18),
          ),
        ],
      ),
    );
  }
}

class _JokerActivationOverlay extends StatefulWidget {
  final JokerType jokerType;
  const _JokerActivationOverlay({required this.jokerType});

  @override
  State<_JokerActivationOverlay> createState() => _JokerActivationOverlayState();
}

class _JokerActivationOverlayState extends State<_JokerActivationOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.1).chain(CurveTween(curve: Curves.elasticOut)), weight: 40),
      TweenSequenceItem(tween: ConstantTween<double>(1.1), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.5).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
    ]).animate(_controller);

    _opacityAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
    ]).animate(_controller);

    _glowAnim = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.6).chain(CurveTween(curve: Curves.easeInOut)), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: 0.6, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.6).chain(CurveTween(curve: Curves.easeInOut)), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: 0.6, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 20),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final joker = JokerModel.getById(widget.jokerType);
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          context.read<GameProvider>().skipJokerAnimation();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              color: Colors.black.withValues(alpha: _opacityAnim.value * 0.85),
              alignment: Alignment.center,
              child: Opacity(
                opacity: _opacityAnim.value,
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1E2D40),
                              boxShadow: [
                                // İç parlama (Beyaz/Sarı)
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.8 * _glowAnim.value),
                                  blurRadius: 15 * _glowAnim.value,
                                  spreadRadius: 2 * _glowAnim.value,
                                ),
                                // Ana parlama (Altın)
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.6 * _glowAnim.value),
                                  blurRadius: 40 * _glowAnim.value,
                                  spreadRadius: 15 * _glowAnim.value,
                                ),
                                // Dış hale (Turuncu)
                                BoxShadow(
                                  color: const Color(0xFFFF8C00).withValues(alpha: 0.4 * _glowAnim.value),
                                  blurRadius: 80 * _glowAnim.value,
                                  spreadRadius: 30 * _glowAnim.value,
                                ),
                              ],
                            ),
                            child: Text(
                              joker.icon,
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                          const SizedBox(height: 40),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _toUpperCaseTr(joker.name),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                    color: const Color(0xFF4A90D9).withValues(alpha: _glowAnim.value),
                                    blurRadius: 16 * _glowAnim.value,
                                  ),
                                  Shadow(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.8 * _glowAnim.value),
                                    blurRadius: 32 * _glowAnim.value,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            );
          },
        ),
      ),
    );
  }

  String _toUpperCaseTr(String text) {
    return text.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
  }
}

class _GameOverContent extends StatefulWidget {
  final GameProvider gameProvider;
  final VoidCallback onGoHome;
  const _GameOverContent({required this.gameProvider, required this.onGoHome});

  @override
  State<_GameOverContent> createState() => _GameOverContentState();
}

class _GameOverContentState extends State<_GameOverContent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _scoreAnim;
  late Animation<double> _scoreScaleAnim;
  late Animation<double> _wordsFoundOpacity;
  late Animation<double> _longestWordOpacity;
  late Animation<double> _availableWordsOpacity;
  late Animation<double> _buttonOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Score counting
    _scoreAnim = IntTween(begin: 0, end: widget.gameProvider.score).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic)),
    );

    // Score pop effect at the end of counting
    _scoreScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeOut)), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)), weight: 45),
    ]).animate(_controller);

    // Staggered fade ins
    _wordsFoundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.65, curve: Curves.easeIn)),
    );

    _longestWordOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.65, 0.8, curve: Curves.easeIn)),
    );

    _availableWordsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.75, 0.9, curve: Curves.easeIn)),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.85, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Text(
                '🏁 OYUN BİTTİ 🏁',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              
              // Glowing Big Score
              Transform.scale(
                scale: _scoreScaleAnim.value,
                child: Column(
                  children: [
                    Text(
                      '${_scoreAnim.value}',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: const Color(0xFF4A90D9).withValues(alpha: 0.8),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                          Shadow(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                            blurRadius: 40,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'TOPLAM PUAN',
                      style: TextStyle(
                        color: Color(0xFF4A90D9),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Stats
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: _wordsFoundOpacity.value,
                        child: _StatCard(
                          icon: Icons.checklist_rtl,
                          title: 'Bulunan Kelime',
                          value: '${widget.gameProvider.foundWords.length}',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Opacity(
                        opacity: _longestWordOpacity.value,
                        child: _StatCard(
                          icon: Icons.text_format,
                          title: 'En Uzun Kelime',
                          value: widget.gameProvider.longestWord.isEmpty ? '-' : widget.gameProvider.longestWord,
                        ),
                      ),
                      
                      if (widget.gameProvider.availableWords.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Opacity(
                          opacity: _availableWordsOpacity.value,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Gözden Kaçan Son Kelimeler',
                                style: TextStyle(
                                  color: Colors.white54, 
                                  fontSize: 13, 
                                  fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: widget.gameProvider.availableWords.map((w) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E2D40),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFF2A4060)),
                                  ),
                                  child: Text(w, style: const TextStyle(color: Colors.white, fontSize: 13)),
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Button
              Opacity(
                opacity: _buttonOpacity.value,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: const Color(0xFF1565C0).withValues(alpha: 0.5),
                    ),
                    onPressed: widget.onGoHome,
                    child: const Text(
                      'ANA MENÜYE DÖN', 
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111820),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2D40)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A90D9), size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

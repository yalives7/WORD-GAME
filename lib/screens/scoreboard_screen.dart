import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_result.dart';
import '../providers/player_provider.dart';
import '../services/storage_service.dart';

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  List<GameResult> _results = [];
  bool _loading = true;

  int get _totalGames => _results.length;
  int get _highScore =>
      _results.isEmpty ? 0 : _results.map((r) => r.score).reduce((a, b) => a > b ? a : b);
  int get _avgScore =>
      _results.isEmpty
          ? 0
          : (_results.map((r) => r.score).reduce((a, b) => a + b) / _results.length).round();
  int get _totalWords =>
      _results.isEmpty ? 0 : _results.map((r) => r.wordCount).reduce((a, b) => a + b);
  int get _totalSeconds =>
      _results.isEmpty ? 0 : _results.map((r) => r.durationSeconds).reduce((a, b) => a + b);
  String get _longestWordEver =>
      _results.isEmpty
          ? '-'
          : _results.map((r) => r.longestWord).reduce((a, b) => a.length >= b.length ? a : b);

  // Sondan başa (en yeni önce)
  List<GameResult> get _byDate => [..._results]..sort((a, b) => b.date.compareTo(a.date));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) _load();
  }

  Future<void> _load() async {
    final username = context.read<PlayerProvider>().username;
    final results = await StorageService.loadResults(username);
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  String _fmtDuration(int s) {
    if (s < 60) return '${s}sn';
    final m = s ~/ 60;
    final sec = s % 60;
    return sec > 0 ? '${m}dk ${sec}sn' : '${m}dk';
  }

  String _fmtTotal(int s) {
    if (s < 60) return '$s saniye';
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    if (h > 0 && m > 0) return '$h sa $m dk';
    if (h > 0) return '$h saat';
    return '$m dakika';
  }

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';

  @override
  Widget build(BuildContext context) {
    final username = context.watch<PlayerProvider>().username;

    return Scaffold(
      backgroundColor: const Color(0xFF080D1A),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700), strokeWidth: 2))
          : _results.isEmpty
              ? _EmptyState(username: username)
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: 210,
                      backgroundColor: const Color(0xFF0D1640),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.pin,
                        background: _ScoreHeader(
                          username: username,
                          highScore: _highScore,
                          totalGames: _totalGames,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _StatsRow(
                        avgScore: _avgScore,
                        totalWords: _totalWords,
                        longestWord: _longestWordEver,
                        totalDuration: _fmtTotal(_totalSeconds),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _ListHeader(count: _results.length),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 48),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) {
                            final r = _byDate[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _GameCard(
                                result: r,
                                fmtDate: _fmtDate,
                                fmtDuration: _fmtDuration,
                              ),
                            );
                          },
                          childCount: _results.length,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _ScoreHeader extends StatelessWidget {
  final String username;
  final int highScore;
  final int totalGames;

  const _ScoreHeader({required this.username, required this.highScore, required this.totalGames});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C2980), Color(0xFF0D1640)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 4),
              // Başlık satırı
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x1FFFD700),
                      border: Border.all(color: const Color(0x55FFD700), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SKOR TABLOSU',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                      Text(
                        username,
                        style: const TextStyle(color: Color(0xAAFFFFFF), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Puan kartları
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _HeaderCard(
                      label: 'EN YÜKSEK PUAN',
                      value: '$highScore',
                      icon: Icons.military_tech_rounded,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _HeaderCard(
                      label: 'TOPLAM OYUN',
                      value: '$totalGames',
                      icon: Icons.sports_esports_rounded,
                      color: const Color(0xFF4A90D9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _HeaderCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color.withValues(alpha: 0.7), size: 14),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 9, letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Row ───────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int avgScore;
  final int totalWords;
  final String longestWord;
  final String totalDuration;

  const _StatsRow({
    required this.avgScore,
    required this.totalWords,
    required this.longestWord,
    required this.totalDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _StatCard(Icons.trending_up_rounded, '$avgScore', 'Ort. Puan', const Color(0xFF26C6DA)),
          const SizedBox(width: 8),
          _StatCard(Icons.text_fields_rounded, '$totalWords', 'Kelimeler', const Color(0xFF66BB6A)),
          const SizedBox(width: 8),
          _StatCard(Icons.workspace_premium_rounded, longestWord, 'En Uzun', const Color(0xFFAB47BC)),
          const SizedBox(width: 8),
          _StatCard(Icons.schedule_rounded, totalDuration, 'Toplam Süre', const Color(0xFFFF7043)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard(this.icon, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─── List Header ──────────────────────────────────────────────────────────────

class _ListHeader extends StatelessWidget {
  final int count;
  const _ListHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          const Text(
            'GEÇMİŞ OYUNLAR',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0x1A4A90D9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('$count', style: const TextStyle(color: Color(0xFF4A90D9), fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

// ─── Game Card ────────────────────────────────────────────────────────────────

class _GameCard extends StatefulWidget {
  final GameResult result;
  final String Function(DateTime) fmtDate;
  final String Function(int) fmtDuration;

  const _GameCard({required this.result, required this.fmtDate, required this.fmtDuration});

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.result;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111D2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2A4060).withValues(alpha: _expanded ? 0.8 : 0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Oyun #${r.gameNumber}',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        widget.fmtDate(r.date),
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${r.score}',
                      style: TextStyle(
                        color: const Color(0xFF4A90D9),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const Text('puan', style: TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white30, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _InfoChip(icon: Icons.grid_4x4_rounded, text: '${r.gridSize}×${r.gridSize}', color: const Color(0xFF4A90D9)),
                const SizedBox(width: 6),
                _InfoChip(icon: Icons.text_fields_rounded, text: '${r.wordCount} kelime', color: const Color(0xFF66BB6A)),
                const SizedBox(width: 6),
                _InfoChip(icon: Icons.timer_rounded, text: widget.fmtDuration(r.durationSeconds), color: const Color(0xFFFF7043)),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              Container(height: 1, color: Colors.white10),
              const SizedBox(height: 12),
              if (r.longestWord.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1B2A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFAB47BC).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: Color(0xFFAB47BC), size: 16),
                      const SizedBox(width: 8),
                      const Text('En Uzun Kelime', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      const Spacer(),
                      Text(
                        r.longestWord,
                        style: const TextStyle(
                          color: Color(0xFFAB47BC),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}


class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoChip({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String username;
  const _EmptyState({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1640),
        foregroundColor: Colors.white,
        title: const Text('SKOR TABLOSU', style: TextStyle(letterSpacing: 2, fontSize: 15)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x10FFD700),
                border: Border.all(color: const Color(0x30FFD700), width: 2),
              ),
              child: const Icon(Icons.leaderboard_rounded, color: Color(0xFFFFD700), size: 36),
            ),
            const SizedBox(height: 24),
            Text(
              username,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Henüz kayıtlı oyun yok.\nİlk oyununu tamamla ve burada görün!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

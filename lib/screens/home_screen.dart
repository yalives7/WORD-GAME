import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import 'grid_select_screen.dart';
import 'scoreboard_screen.dart';
import 'market_screen.dart';
import 'username_screen.dart';
import '../widgets/how_to_play_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showUserDialog(BuildContext context, PlayerProvider playerProvider) {
    final controller = TextEditingController(text: playerProvider.username);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Profil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ad değiştir
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF0D1B2A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4A90D9), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final newName = controller.text.trim();
                  if (newName.isNotEmpty && newName != playerProvider.username) {
                    await playerProvider.updateUsername(newName);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Adı Güncelle', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const Divider(color: Colors.white24, height: 32),
            // Kullanıcı geçişi
            if (playerProvider.allUsers.length > 1) ...[
              const Text('Kullanıcı Değiştir', style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...playerProvider.allUsers
                  .where((u) => u != playerProvider.username)
                  .map((u) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF2A4060), width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.switch_account, size: 20),
                            label: Text(u, style: const TextStyle(fontWeight: FontWeight.w500)),
                            onPressed: () async {
                              await playerProvider.switchUser(u);
                              if (ctx.mounted) Navigator.pop(ctx);
                            },
                          ),
                        ),
                      )),
            ],
            // Yeni kullanıcı ekle
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                icon: const Icon(Icons.person_add, size: 20, color: Color(0xFF4A90D9)),
                label: const Text('Yeni Kullanıcı Ekle', style: TextStyle(color: Color(0xFF4A90D9), fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UsernameScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<PlayerProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0F1E), Color(0xFF131B2F)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Üst bar: kullanıcı adı (sol) + altın (sağ)
                Row(
                  children: [
                    // Kullanıcı adı butonu
                    GestureDetector(
                      onTap: () => _showUserDialog(context, playerProvider),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2D40).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFF2A4060)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person, color: Color(0xFF4A90D9), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              playerProvider.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.edit, color: Colors.white38, size: 14),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Bilgi (Nasıl Oynanır) Butonu
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2D40).withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF2A4060)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tips_and_updates_rounded, color: Color(0xFFFFD700), size: 20),
                        onPressed: () => HowToPlayDialog.show(context),
                        tooltip: 'Nasıl Oynanır?',
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Altın
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2D40).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${playerProvider.gold}',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 2),

                // Başlık
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2639).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: const Color(0xFF2A4060).withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'KELİME',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          height: 1.1,
                          shadows: [Shadow(color: Color(0xFF4A90D9), blurRadius: 12)],
                        ),
                      ),
                      Text(
                        'AVCISI',
                        style: TextStyle(
                          color: const Color(0xFF4A90D9),
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          height: 1.1,
                          shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Zeka ve Dikkat Oyunu',
                  style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 1.2, fontWeight: FontWeight.w500),
                ),

                const Spacer(flex: 3),

                // Menü butonları
                _AnimatedPlayButton(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GridSelectScreen()),
                  ),
                ),
                const SizedBox(height: 20),
                _MenuButton(
                  icon: Icons.leaderboard_rounded,
                  label: 'SKOR TABLOSU',
                  gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)]),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScoreboardScreen()),
                  ),
                ),
                const SizedBox(height: 16),
                _MenuButton(
                  icon: Icons.storefront_rounded,
                  label: 'MARKET',
                  gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)]),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MarketScreen()),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedPlayButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AnimatedPlayButton({required this.onTap});

  @override
  State<_AnimatedPlayButton> createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<_AnimatedPlayButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1976D2).withValues(alpha: 0.5),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: widget.onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'OYNA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

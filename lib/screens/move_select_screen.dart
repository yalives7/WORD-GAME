import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/player_provider.dart';
import 'game_screen.dart';

class MoveSelectScreen extends StatelessWidget {
  final int gridSize;

  const MoveSelectScreen({super.key, required this.gridSize});

  String _gridLabel() {
    switch (gridSize) {
      case 6:
        return '6×6 (Zor)';
      case 8:
        return '8×8 (Orta)';
      case 10:
        return '10×10 (Kolay)';
      default:
        return '$gridSize×$gridSize';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Hamle Sayısı Seç', style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0F1E), Color(0xFF131B2F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Seçilen grid bilgisi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2D40).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.grid_on_rounded, color: Color(0xFF4A90D9), size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Seçilen Grid: ${_gridLabel()}',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _MoveOption(
                  label: 'Kolay',
                  moves: 25,
                  icon: '🌱',
                  gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)]),
                  description: '25 Hamle',
                  gridSize: gridSize,
                ),
                const SizedBox(height: 16),
                _MoveOption(
                  label: 'Orta',
                  moves: 20,
                  icon: '⚡',
                  gradient: const LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF0D47A1)]),
                  description: '20 Hamle',
                  gridSize: gridSize,
                ),
                const SizedBox(height: 16),
                _MoveOption(
                  label: 'Zor',
                  moves: 15,
                  icon: '🔥',
                  gradient: const LinearGradient(colors: [Color(0xFFC62828), Color(0xFFB71C1C)]),
                  description: '15 Hamle',
                  gridSize: gridSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MoveOption extends StatelessWidget {
  final String label;
  final int moves;
  final String icon;
  final Gradient gradient;
  final String description;
  final int gridSize;

  const _MoveOption({
    required this.label,
    required this.moves,
    required this.icon,
    required this.gradient,
    required this.description,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          onTap: () async {
            final gameProvider = context.read<GameProvider>();
            final username = context.read<PlayerProvider>().username;

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );

            await gameProvider.startGame(gridSize, moves, username);

            if (context.mounted) {
              Navigator.pop(context); // loading dialog kapat
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const GameScreen()),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(description, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

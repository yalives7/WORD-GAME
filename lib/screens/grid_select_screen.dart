import 'package:flutter/material.dart';
import 'move_select_screen.dart';

class GridSelectScreen extends StatelessWidget {
  const GridSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Grid Boyutu Seç', style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.bold)),
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
                const SizedBox(height: 32),
                _GridOption(
                  size: 10,
                  label: 'Kolay',
                  description: '10×10 Grid',
                  gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)]),
                  icon: '🌱',
                ),
                const SizedBox(height: 16),
                _GridOption(
                  size: 8,
                  label: 'Orta',
                  description: '8×8 Grid',
                  gradient: const LinearGradient(colors: [Color(0xFF1976D2), Color(0xFF0D47A1)]),
                  icon: '⚡',
                ),
                const SizedBox(height: 16),
                _GridOption(
                  size: 6,
                  label: 'Zor',
                  description: '6×6 Grid',
                  gradient: const LinearGradient(colors: [Color(0xFFC62828), Color(0xFFB71C1C)]),
                  icon: '🔥',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridOption extends StatelessWidget {
  final int size;
  final String label;
  final String description;
  final Gradient gradient;
  final String icon;

  const _GridOption({
    required this.size,
    required this.label,
    required this.description,
    required this.gradient,
    required this.icon,
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MoveSelectScreen(gridSize: size),
              ),
            );
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
                    Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
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

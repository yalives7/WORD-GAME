import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/joker_model.dart';
import '../providers/game_provider.dart';
import '../providers/player_provider.dart';

class JokerBarWidget extends StatelessWidget {
  const JokerBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final playerProvider = context.watch<PlayerProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0D1B2A).withValues(alpha: 0.9),
            const Color(0xFF09121C),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, -4),
          )
        ],
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: JokerModel.all.map((joker) {
          final count = playerProvider.jokerCount(joker.type);
          final isActive = gameProvider.activeJoker == joker.type;
          final hasJokers = count > 0;
          final canUse = hasJokers && !gameProvider.gameOver;

          return _JokerButton(
            joker: joker,
            count: count,
            isActive: isActive,
            canUse: canUse,
            onTap: () {
              if (isActive) {
                gameProvider.cancelJoker();
              } else {
                gameProvider.activateJoker(
                  joker.type,
                  onUsed: (type) => playerProvider.useJoker(type),
                );
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

class _JokerButton extends StatefulWidget {
  final JokerModel joker;
  final int count;
  final bool isActive;
  final bool canUse;
  final VoidCallback onTap;

  const _JokerButton({
    required this.joker,
    required this.count,
    required this.isActive,
    required this.canUse,
    required this.onTap,
  });

  @override
  State<_JokerButton> createState() => _JokerButtonState();
}

class _JokerButtonState extends State<_JokerButton>
    with TickerProviderStateMixin {
  late AnimationController _tapController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _breatheAnim;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _glowAnim = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _breatheAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!widget.canUse && !widget.isActive) return;
    await _tapController.forward();
    await _tapController.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (widget.canUse || widget.isActive) ? _handleTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final scale = (widget.canUse && !widget.isActive) ? _breatheAnim.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: ScaleTransition(
          scale: _scaleAnim,
          child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: widget.canUse ? 1.0 : 0.4,
          child: SizedBox(
            width: 56,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Aktif ise arkada parlayan efekt
                if (widget.isActive)
                  AnimatedBuilder(
                    animation: _glowAnim,
                    builder: (context, child) {
                      return Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                              blurRadius: _glowAnim.value,
                              spreadRadius: _glowAnim.value / 2,
                            ),
                            BoxShadow(
                              color: const Color(0xFFFF8C00).withValues(alpha: 0.3),
                              blurRadius: _glowAnim.value * 2,
                              spreadRadius: _glowAnim.value,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                
                // Sembolün Kendisi (Hafif iç gölgeli veya glassmorphism)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.canUse 
                          ? [Colors.white.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.02)]
                          : [Colors.transparent, Colors.transparent],
                    ),
                    border: Border.all(
                      color: widget.canUse 
                          ? Colors.white.withValues(alpha: 0.2) 
                          : Colors.transparent,
                      width: 1,
                    ),
                    boxShadow: widget.canUse && !widget.isActive ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ] : null,
                  ),
                  child: Center(
                    child: Text(
                      widget.joker.icon,
                      style: TextStyle(
                        fontSize: 26,
                        shadows: widget.canUse ? [
                          const Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(1, 1),
                          )
                        ] : null,
                      ),
                    ),
                  ),
                ),
                
                // Adet Rozeti (Badge)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.canUse ? const Color(0xFFE53935) : const Color(0xFF424242),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF09121C), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      widget.count > 0 ? '${widget.count}' : '0',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

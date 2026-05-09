import 'package:flutter/material.dart';
import 'dart:math';
import '../models/cell_model.dart';
import '../utils/letter_data.dart';

class CellWidget extends StatefulWidget {
  final CellModel cell;
  final double size;

  const CellWidget({super.key, required this.cell, required this.size});

  @override
  State<CellWidget> createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget> with TickerProviderStateMixin {
  late AnimationController _explodeController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Patlama animasyonu (0.6 saniye) - hızlı ve agresif
    _explodeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Ölçek animasyonu - ani patlatma
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _explodeController, curve: Curves.easeInQuad),
    );

    // Opasite animasyonu - sönme
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _explodeController, curve: Curves.easeInQuad),
    );

    // İkinci animasyon: şok dalgası
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // İlk patlama tetikleyici
    if (widget.cell.isDestroyed) {
      _triggerExplode();
    }
  }

  @override
  void didUpdateWidget(CellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Yeni patlama tetiklenirse başlat
    if (widget.cell.isDestroyed && !oldWidget.cell.isDestroyed) {
      _triggerExplode();
    }
  }

  void _triggerExplode() {
    _explodeController.reset();
    _explodeController.forward().then((_) {
      // Patlama bittikten sonra da hiç hareket etme (already destroyed)
    });
  }

  @override
  void dispose() {
    _explodeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cell.isEmpty && !widget.cell.isDestroyed) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    final isSelected = widget.cell.isSelected;
    final hasPower = widget.cell.specialPower != null;

    Color bgColor;
    Color borderColor;
    Color textColor = Colors.white;

    if (isSelected) {
      bgColor = const Color(0xFF5C6BC0);
      borderColor = const Color(0xFF3949AB);
    } else if (hasPower) {
      switch (widget.cell.specialPower!) {
        case SpecialPower.rowClear:
          bgColor = const Color(0xFFE91E63);
          borderColor = const Color(0xFFC2185B);
        case SpecialPower.areaBomb:
          bgColor = const Color(0xFFFF5722);
          borderColor = const Color(0xFFE64A19);
        case SpecialPower.columnClear:
          bgColor = const Color(0xFF9C27B0);
          borderColor = const Color(0xFF7B1FA2);
        case SpecialPower.megaBomb:
          bgColor = const Color(0xFFFF9800);
          borderColor = const Color(0xFFF57C00);
      }
    } else {
      bgColor = const Color(0xFF1565C0);
      borderColor = const Color(0xFF0D47A1);
    }

    final score = LetterData.getScore(widget.cell.letter);

    // Patlama animasyonu uygula
    if (widget.cell.isDestroyed) {
      return AnimatedBuilder(
        animation: Listenable.merge([_explodeController, _scaleController]),
        builder: (context, child) {
          final progress = _explodeController.value;

          // Parçacıklar - dış tarafa doğru uçan efekt
          final particles = <Widget>[];
          for (int i = 0; i < 8; i++) {
            final angle = (i / 8) * pi * 2;
            final distance = widget.size * 0.5 * progress;
            final x = distance * cos(angle);
            final y = distance * sin(angle);

            particles.add(
              Positioned(
                left: widget.size / 2 - 3 + x,
                top: widget.size / 2 - 3 + y,
                child: Opacity(
                  opacity: (1.0 - progress).clamp(0, 1),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        Colors.yellow,
                        Colors.orange,
                        progress,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.yellow
                              .withValues(alpha: 0.8 * (1.0 - progress)),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return Stack(
            children: [
              // Ana hücre - merkeze doğru çöküyor
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: [
                        // Ana ışık - sarı parlak
                        BoxShadow(
                          color: Colors.yellow
                              .withValues(alpha: 0.9 * (1.0 - progress)),
                          blurRadius: 24 * (1.0 - progress),
                          spreadRadius: 12 * (1.0 - progress),
                        ),
                        // İkincil ışık - portakal
                        BoxShadow(
                          color: Colors.orange
                              .withValues(alpha: 0.6 * (1.0 - progress)),
                          blurRadius: 16 * (1.0 - progress),
                          spreadRadius: 8 * (1.0 - progress),
                        ),
                        // Kırmızı çekirdek
                        BoxShadow(
                          color: Colors.red
                              .withValues(alpha: 0.4 * (1.0 - progress)),
                          blurRadius: 8 * (1.0 - progress),
                          spreadRadius: 4 * (1.0 - progress),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            widget.cell.letter,
                            style: TextStyle(
                              color: textColor,
                              fontSize: widget.size * 0.38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (hasPower)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Text(
                              widget.cell.specialPowerSymbol,
                              style: TextStyle(fontSize: widget.size * 0.22),
                            ),
                          ),
                        Positioned(
                          bottom: 1,
                          right: 3,
                          child: Text(
                            '$score',
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.7),
                              fontSize: widget.size * 0.18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Parçacıklar
              ...particles,
            ],
          );
        },
      );
    }

    // Normal durum
    return Container(
      width: widget.size,
      height: widget.size,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: isSelected
            ? [
                BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2)
              ]
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              widget.cell.letter,
              style: TextStyle(
                color: textColor,
                fontSize: widget.size * 0.38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (hasPower)
            Positioned(
              top: 2,
              right: 2,
              child: Text(
                widget.cell.specialPowerSymbol,
                style: TextStyle(fontSize: widget.size * 0.22),
              ),
            ),
          Positioned(
            bottom: 1,
            right: 3,
            child: Text(
              '$score',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: widget.size * 0.18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

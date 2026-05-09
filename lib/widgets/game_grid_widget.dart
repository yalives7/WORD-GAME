import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'cell_widget.dart';

class GameGridWidget extends StatefulWidget {
  const GameGridWidget({super.key});

  @override
  State<GameGridWidget> createState() => _GameGridWidgetState();
}

class _GameGridWidgetState extends State<GameGridWidget> {
  List<int>? _cellFromOffset(Offset localOffset, int size, double cellSize) {
    final col = (localOffset.dx / cellSize).floor();
    final row = (localOffset.dy / cellSize).floor();
    if (row >= 0 && row < size && col >= 0 && col < size) {
      return [row, col];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final size = gameProvider.gridSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        final gridWidth = constraints.maxWidth;
        final cellSize = gridWidth / size;

        return GestureDetector(
          // Pan: kelime seçimi veya joker (sürükle)
          onPanStart: (details) {
            final cell = _cellFromOffset(details.localPosition, size, cellSize);
            if (cell != null) {
              gameProvider.onPanStart(cell[0], cell[1]);
            }
          },
          onPanUpdate: (details) {
            final cell = _cellFromOffset(details.localPosition, size, cellSize);
            if (cell != null) {
              gameProvider.onPanUpdate(cell[0], cell[1]);
            }
          },
          onPanEnd: (_) {
            gameProvider.onPanEnd();
          },
          // Tap: joker seçimi veya tek tek harf seçimi için
          onTapUp: (details) {
            final cell = _cellFromOffset(details.localPosition, size, cellSize);
            if (cell != null) {
              gameProvider.onCellTap(cell[0], cell[1]);
            }
          },
          child: SizedBox(
            width: gridWidth,
            height: gridWidth,
            child: Stack(
              children: [
                for (int r = 0; r < size; r++)
                  for (int c = 0; c < size; c++)
                    AnimatedPositioned(
                      key: ValueKey(gameProvider.grid[r][c].id),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.bounceOut,
                      top: r * cellSize,
                      left: c * cellSize,
                      width: cellSize,
                      height: cellSize,
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey('spawn_${gameProvider.grid[r][c].id}'),
                        tween: Tween(begin: -gridWidth, end: 0.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.bounceOut,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, value),
                            child: child,
                          );
                        },
                        child: CellWidget(
                          cell: gameProvider.grid[r][c],
                          size: cellSize - 4,
                        ),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

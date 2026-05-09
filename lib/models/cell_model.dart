import 'package:flutter/foundation.dart';

enum SpecialPower { rowClear, areaBomb, columnClear, megaBomb }

class CellModel {
  final String id;
  final int row;
  final int col;
  String letter;
  bool isSelected;
  bool isEmpty;
  bool isDestroyed; // Patlatma animasyonu için
  SpecialPower? specialPower;

  CellModel({
    String? id,
    required this.row,
    required this.col,
    required this.letter,
    this.isSelected = false,
    this.isEmpty = false,
    this.isDestroyed = false,
    this.specialPower,
  }) : id = id ?? UniqueKey().toString();

  String get specialPowerSymbol {
    switch (specialPower) {
      case SpecialPower.rowClear:
        return '⇆';
      case SpecialPower.areaBomb:
        return '✹';
      case SpecialPower.columnClear:
        return '⇅';
      case SpecialPower.megaBomb:
        return '✪';
      case null:
        return '';
    }
  }

  CellModel copyWith({
    String? id,
    int? row,
    int? col,
    String? letter,
    bool? isSelected,
    bool? isEmpty,
    bool? isDestroyed,
    SpecialPower? specialPower,
    bool clearSpecialPower = false,
  }) {
    return CellModel(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      letter: letter ?? this.letter,
      isSelected: isSelected ?? this.isSelected,
      isEmpty: isEmpty ?? this.isEmpty,
      isDestroyed: isDestroyed ?? this.isDestroyed,
      specialPower:
          clearSpecialPower ? null : (specialPower ?? this.specialPower),
    );
  }
}

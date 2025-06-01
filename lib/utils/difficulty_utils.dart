import 'package:flutter/material.dart';

Map<String, List<int>> thresholds = {
  'EASY': [1, 10, 20, 30],
  'NORMAL': [1, 10, 20, 30],
  'HARD': [1, 10, 20, 30],
  'LEGEND': [1, 10, 20, 30],
};

int getPlantStage(int clearedCount, List<int> thresholds) {
  for (int i = 0; i < thresholds.length; i++) {
    if (clearedCount < thresholds[i]) {
      return i;
    }
  }
  return thresholds.length;
}

Color getDifficultyColor(String difficulty) {
  switch (difficulty) {
    case 'EASY':
      return Colors.blue;
    case 'NORMAL':
      return Colors.green;
    case 'HARD':
      return Colors.red;
    case 'LEGEND':
      return Colors.lime;
    default:
      return Colors.grey;
  }
}

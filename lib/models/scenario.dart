import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roi_calculator/logic/calculator_logic.dart';

/// A saved calculator scenario (inputs only; results are computed on load).
class Scenario {
  const Scenario({
    required this.id,
    required this.name,
    required this.billAmount,
    required this.isMonthly,
    required this.windowPercent,
    required this.projectCost,
    required this.climate,
    required this.yearsSlider,
    required this.createdAt,
  });

  final String id;
  final String name;
  final double billAmount;
  final bool isMonthly;
  final double windowPercent;
  final double projectCost;
  final Climate climate;
  final int yearsSlider;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'billAmount': billAmount,
      'isMonthly': isMonthly,
      'windowPercent': windowPercent,
      'projectCost': projectCost,
      'climate': climate.name,
      'yearsSlider': yearsSlider,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static Scenario fromFirestore(String id, Map<String, Object?> map) {
    final createdAt = map['createdAt'];
    return Scenario(
      id: id,
      name: (map['name'] as String?) ?? '',
      billAmount: (map['billAmount'] as num?)?.toDouble() ?? 0,
      isMonthly: (map['isMonthly'] as bool?) ?? true,
      windowPercent: (map['windowPercent'] as num?)?.toDouble() ?? 15,
      projectCost: (map['projectCost'] as num?)?.toDouble() ?? 0,
      climate: _climateFromString(map['climate'] as String?),
      yearsSlider: (map['yearsSlider'] as int?) ?? 10,
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.now(),
    );
  }

  static Climate _climateFromString(String? value) {
    switch (value) {
      case 'cold':
        return Climate.cold;
      case 'hot':
        return Climate.hot;
      case 'moderate':
      default:
        return Climate.moderate;
    }
  }
}

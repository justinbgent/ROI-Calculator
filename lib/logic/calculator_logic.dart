// Pure calculation logic for window replacement savings & ROI.
// Savings factors by climate are tunable here.

enum Climate {
  cold,
  moderate,
  hot,
}

abstract class CalculatorLogic {
  CalculatorLogic._();

  /// Savings factor: fraction of window-attributed cost saved after replacement.
  static const double coldFactor = 0.35;
  static const double moderateFactor = 0.28;
  static const double hotFactor = 0.22;

  static double _savingsFactorFor(Climate climate) {
    switch (climate) {
      case Climate.cold:
        return coldFactor;
      case Climate.moderate:
        return moderateFactor;
      case Climate.hot:
        return hotFactor;
    }
  }

  /// Returns annual bill in dollars. [amount] is the user-entered value;
  /// if [isMonthly] is true, it's multiplied by 12.
  static double getAnnualBill(double amount, bool isMonthly) {
    if (amount <= 0) return 0;
    return isMonthly ? amount * 12 : amount;
  }

  /// Estimated annual savings from replacing windows.
  /// [annualBill] = full annual heating/cooling bill,
  /// [windowPercent] = 0..100 (percentage attributed to windows),
  /// [climate] = region for savings factor.
  static double getAnnualSavings(
    double annualBill,
    double windowPercent,
    Climate climate,
  ) {
    if (annualBill <= 0 || windowPercent <= 0) return 0;
    final windowPortion = annualBill * (windowPercent / 100);
    return windowPortion * _savingsFactorFor(climate);
  }

  /// Payback in years (project cost / annual savings).
  /// Returns null if annualSavings <= 0 to avoid division by zero.
  static double? getPaybackYears(double projectCost, double annualSavings) {
    if (projectCost <= 0 || annualSavings <= 0) return null;
    return projectCost / annualSavings;
  }
}

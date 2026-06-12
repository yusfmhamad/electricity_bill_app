class ElectricityCalculator {
  /// Calculates total charges based on tiered block pricing (in RM)
  static double calculateTotalCharges(double units) {
    double total = 0.0;

    if (units <= 0) return 0.0;

    // Block 1: 1 - 200 kWh @ 21.8 sen/kWh
    if (units <= 200) {
      total = units * 0.218;
    } else {
      total += 200 * 0.218; // RM 43.60
      double remaining = units - 200;

      // Block 2: 201 - 300 kWh @ 33.4 sen/kWh
      if (remaining <= 100) {
        total += remaining * 0.334;
      } else {
        total += 100 * 0.334; // RM 33.40
        remaining -= 100;

        // Block 3: 301 - 600 kWh @ 51.6 sen/kWh
        if (remaining <= 300) {
          total += remaining * 0.516;
        } else {
          total += 300 * 0.516; // RM 154.80
          remaining -= 300;

          // Block 4: 601 - 1000 kWh @ 54.6 sen/kWh
          total += remaining * 0.546;
        }
      }
    }

    return double.parse(total.toStringAsFixed(3));
  }

  /// Calculates final cost after applying rebate
  static double calculateFinalCost(double totalCharges, double rebatePercent) {
    final rebate = totalCharges * (rebatePercent / 100);
    final finalCost = totalCharges - rebate;
    return double.parse(finalCost.toStringAsFixed(3));
  }
}

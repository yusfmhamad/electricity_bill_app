class BillRecord {
  int? id;
  String month;
  double unitUsed;
  double rebatePercentage;
  double totalCharges;
  double finalCost;
  String createdAt;

  BillRecord({
    this.id,
    required this.month,
    required this.unitUsed,
    required this.rebatePercentage,
    required this.totalCharges,
    required this.finalCost,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'unit_used': unitUsed,
      'rebate_percentage': rebatePercentage,
      'total_charges': totalCharges,
      'final_cost': finalCost,
      'created_at': createdAt,
    };
  }

  factory BillRecord.fromMap(Map<String, dynamic> map) {
    return BillRecord(
      id: map['id'],
      month: map['month'],
      unitUsed: map['unit_used'],
      rebatePercentage: map['rebate_percentage'],
      totalCharges: map['total_charges'],
      finalCost: map['final_cost'],
      createdAt: map['created_at'],
    );
  }
}

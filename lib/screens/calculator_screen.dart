import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/bill_record.dart';
import '../utils/electricity_calculator.dart';
import '../utils/app_theme.dart';
import 'history_screen.dart';
import 'about_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unitController = TextEditingController();

  String? _selectedMonth;
  double _rebatePercentage = 0.0;
  double? _totalCharges;
  double? _finalCost;
  bool _isSaved = false;
  bool _isCalculated = false;

  @override
  void dispose() {
    _unitController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      final units = double.parse(_unitController.text);
      final total = ElectricityCalculator.calculateTotalCharges(units);
      final finalC = ElectricityCalculator.calculateFinalCost(total, _rebatePercentage);
      setState(() {
        _totalCharges = total;
        _finalCost = finalC;
        _isCalculated = true;
        _isSaved = false;
      });
    }
  }

  Future<void> _saveToDatabase() async {
    if (_totalCharges == null || _finalCost == null || _selectedMonth == null) return;
    final units = double.parse(_unitController.text);
    final record = BillRecord(
      month: _selectedMonth!,
      unitUsed: units,
      rebatePercentage: _rebatePercentage,
      totalCharges: _totalCharges!,
      finalCost: _finalCost!,
      createdAt: DateTime.now().toIso8601String(),
    );
    await DatabaseHelper.instance.insertBill(record);
    setState(() => _isSaved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Record saved successfully!'),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _reset() {
    setState(() {
      _formKey.currentState?.reset();
      _unitController.clear();
      _selectedMonth = null;
      _rebatePercentage = 0.0;
      _totalCharges = null;
      _finalCost = null;
      _isCalculated = false;
      _isSaved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'RM ', decimalDigits: 3);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.electric_bolt, color: Colors.amber, size: 24),
            SizedBox(width: 8),
            Text('⚡ Bill Estimator'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Bill History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentColor.withOpacity(0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: AppTheme.primaryColor, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Select a month, enter your kWh usage (1–1000), and choose a rebate to estimate your electricity bill.',
                        style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Input Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📋 Bill Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Month Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedMonth,
                        decoration: const InputDecoration(
                          labelText: 'Month *',
                          prefixIcon: Icon(Icons.calendar_month),
                          hintText: 'Select a month',
                        ),
                        items: AppConstants.months.map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m),
                        )).toList(),
                        onChanged: (val) => setState(() => _selectedMonth = val),
                        validator: (val) => val == null ? 'Please select a month' : null,
                      ),
                      const SizedBox(height: 16),

                      // Unit Input
                      TextFormField(
                        controller: _unitController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Electricity Units (kWh) *',
                          prefixIcon: Icon(Icons.electric_meter),
                          hintText: 'Enter units (1 - 1000)',
                          suffixText: 'kWh',
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please enter units used';
                          final n = double.tryParse(val);
                          if (n == null) return 'Please enter a valid number';
                          if (n < 1) return 'Minimum is 1 kWh';
                          if (n > 1000) return 'Maximum is 1000 kWh';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Rebate Slider
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.discount, color: AppTheme.primaryColor, size: 20),
                                  SizedBox(width: 6),
                                  Text('Rebate Percentage', style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_rebatePercentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _rebatePercentage,
                            min: 0,
                            max: 5,
                            divisions: 10,
                            activeColor: AppTheme.primaryColor,
                            inactiveColor: AppTheme.accentColor.withOpacity(0.3),
                            label: '${_rebatePercentage.toStringAsFixed(1)}%',
                            onChanged: (val) => setState(() => _rebatePercentage = val),
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('0%', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              Text('5%', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _calculate,
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: const BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Result Card
              if (_isCalculated && _totalCharges != null && _finalCost != null) ...[
                Card(
                  color: AppTheme.primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          '💡 Calculation Result',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ResultRow(
                          label: 'Month',
                          value: _selectedMonth ?? '-',
                          icon: Icons.calendar_today,
                        ),
                        _ResultRow(
                          label: 'Units Used',
                          value: '${_unitController.text} kWh',
                          icon: Icons.electric_bolt,
                        ),
                        _ResultRow(
                          label: 'Rebate',
                          value: '${_rebatePercentage.toStringAsFixed(1)}%',
                          icon: Icons.discount,
                        ),
                        const Divider(color: Colors.white38, height: 24),
                        _ResultRow(
                          label: 'Total Charges',
                          value: currencyFormat.format(_totalCharges),
                          icon: Icons.receipt,
                          isHighlight: false,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 8),
                              const Text(
                                'Final Cost (After Rebate):',
                                style: TextStyle(color: Colors.white, fontSize: 14),
                              ),
                              const Spacer(),
                              Text(
                                currencyFormat.format(_finalCost),
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaved ? null : _saveToDatabase,
                            icon: Icon(_isSaved ? Icons.check : Icons.save),
                            label: Text(_isSaved ? 'Saved ✓' : 'Save to Database'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isSaved ? AppTheme.successColor : Colors.amber,
                              foregroundColor: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Rate table hint
                _RateTableCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlight;

  const _ResultRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? Colors.amber : Colors.white,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              fontSize: isHighlight ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _RateTableCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Tariff Rate Table',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(color: AppTheme.accentColor.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
              columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(2)},
              children: [
                _tableHeader(),
                _tableRow('1 – 200 kWh', '21.8 sen/kWh', true),
                _tableRow('201 – 300 kWh', '33.4 sen/kWh', false),
                _tableRow('301 – 600 kWh', '51.6 sen/kWh', true),
                _tableRow('601 – 1000 kWh', '54.6 sen/kWh', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _tableHeader() {
    return TableRow(
      decoration: const BoxDecoration(color: AppTheme.primaryColor),
      children: [
        _cell('Block', isHeader: true),
        _cell('Rate', isHeader: true),
      ],
    );
  }

  TableRow _tableRow(String block, String rate, bool shaded) {
    return TableRow(
      decoration: BoxDecoration(
        color: shaded ? AppTheme.backgroundColor : Colors.white,
      ),
      children: [_cell(block), _cell(rate)],
    );
  }

  Widget _cell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.white : AppTheme.textPrimary,
        ),
      ),
    );
  }
}

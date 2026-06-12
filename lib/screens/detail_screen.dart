import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/bill_record.dart';
import '../utils/app_theme.dart';
import '../utils/electricity_calculator.dart';

class DetailScreen extends StatefulWidget {
  final int billId;
  const DetailScreen({super.key, required this.billId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  BillRecord? _bill;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final _unitController = TextEditingController();
  String? _editMonth;
  double _editRebate = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBill();
  }

  Future<void> _loadBill() async {
    final bill = await DatabaseHelper.instance.getBillById(widget.billId);
    setState(() {
      _bill = bill;
      if (bill != null) {
        _editMonth = bill.month;
        _editRebate = bill.rebatePercentage;
        _unitController.text = bill.unitUsed.toStringAsFixed(0);
      }
    });
  }

  Future<void> _saveEdit() async {
    if (!_formKey.currentState!.validate() || _bill == null) return;
    final units = double.parse(_unitController.text);
    final total = ElectricityCalculator.calculateTotalCharges(units);
    final finalCost = ElectricityCalculator.calculateFinalCost(total, _editRebate);

    final updated = BillRecord(
      id: _bill!.id,
      month: _editMonth!,
      unitUsed: units,
      rebatePercentage: _editRebate,
      totalCharges: total,
      finalCost: finalCost,
      createdAt: _bill!.createdAt,
    );

    await DatabaseHelper.instance.updateBill(updated);
    setState(() {
      _bill = updated;
      _isEditing = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Record updated successfully!'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _deleteRecord() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this bill record? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && _bill?.id != null) {
      await DatabaseHelper.instance.deleteBill(_bill!.id!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'RM ', decimalDigits: 3);

    if (_bill == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Record' : 'Bill Detail'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: _deleteRecord,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _isEditing ? _buildEditForm() : _buildDetailView(currencyFormat),
      ),
    );
  }

  Widget _buildDetailView(NumberFormat currencyFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: AppTheme.primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.receipt_long, color: Colors.white, size: 40),
                const SizedBox(height: 8),
                Text(
                  _bill!.month,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bill Record #${_bill!.id}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                const Divider(),
                _DetailRow(icon: Icons.calendar_month, label: 'Month', value: _bill!.month),
                _DetailRow(icon: Icons.electric_meter, label: 'Units Used', value: '${_bill!.unitUsed.toStringAsFixed(0)} kWh'),
                _DetailRow(icon: Icons.discount, label: 'Rebate', value: '${_bill!.rebatePercentage.toStringAsFixed(1)}%'),
                const Divider(),
                _DetailRow(icon: Icons.receipt, label: 'Total Charges', value: currencyFormat.format(_bill!.totalCharges)),
                _DetailRow(
                  icon: Icons.star,
                  label: 'Final Cost',
                  value: currencyFormat.format(_bill!.finalCost),
                  highlight: true,
                ),
                const Divider(),
                _DetailRow(
                  icon: Icons.access_time,
                  label: 'Saved At',
                  value: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(_bill!.createdAt)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _deleteRecord,
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit Record', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _editMonth,
                    decoration: const InputDecoration(labelText: 'Month *', prefixIcon: Icon(Icons.calendar_month)),
                    items: AppConstants.months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (val) => setState(() => _editMonth = val),
                    validator: (val) => val == null ? 'Please select a month' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _unitController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Electricity Units (kWh) *',
                      prefixIcon: Icon(Icons.electric_meter),
                      suffixText: 'kWh',
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      final n = double.tryParse(val);
                      if (n == null) return 'Invalid number';
                      if (n < 1) return 'Min 1 kWh';
                      if (n > 1000) return 'Max 1000 kWh';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Rebate Percentage', style: TextStyle(color: AppTheme.textSecondary)),
                      Text('${_editRebate.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    ],
                  ),
                  Slider(
                    value: _editRebate,
                    min: 0, max: 5, divisions: 10,
                    activeColor: AppTheme.primaryColor,
                    onChanged: (val) => setState(() => _editRebate = val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveEdit,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => setState(() => _isEditing = false),
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                  side: const BorderSide(color: AppTheme.errorColor),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _unitController.dispose();
    super.dispose();
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: highlight ? AppTheme.primaryColor : AppTheme.textPrimary,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              fontSize: highlight ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 22),
            SizedBox(width: 8),
            Text('About'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App Header
            Card(
              color: AppTheme.primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.electric_bolt,
                          color: AppTheme.primaryColor, size: 48),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '⚡ Electricity Bill Estimator',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Version 1.0.0',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Student Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '👤 Student Information',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor),
                    ),
                    const Divider(),
                    // Profile Picture Placeholder
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppTheme.primaryColor, width: 2),
                        ),
                        child: const Icon(Icons.person,
                            size: 60, color: AppTheme.primaryColor),
                      ),
                    ),
                    const _InfoRow(
                        icon: Icons.person,
                        label: 'Full Name',
                        value: 'Yusf Mhamad'),
                    const _InfoRow(
                        icon: Icons.badge,
                        label: 'Student ID',
                        value: 'Qiu23-0384'),
                    const _InfoRow(
                        icon: Icons.school,
                        label: 'Course Code',
                        value: 'ICT602'),
                    const _InfoRow(
                        icon: Icons.book,
                        label: 'Course Name',
                        value: 'Mobile Technology'),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '© ${DateTime.now().year} Yusf Mhamad. All rights reserved.',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // GitHub Link
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _launchUrl(
                    'https://github.com/yusfmhamad/electricity-bill-app'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF24292E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.code,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('GitHub Repository',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                    fontSize: 16)),
                            Text('github.com/yusfmhamad/electricity-bill-app',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      const Icon(Icons.open_in_new,
                          color: AppTheme.primaryColor),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // How to Use Card
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📖 How to Use the App',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor),
                    ),
                    Divider(),
                    _StepRow(
                      step: '1',
                      title: 'Select Month',
                      description:
                          'Choose the billing month from the dropdown menu on the main screen.',
                    ),
                    _StepRow(
                      step: '2',
                      title: 'Enter Units Used',
                      description:
                          'Type your electricity consumption in kWh (minimum 1, maximum 1000).',
                    ),
                    _StepRow(
                      step: '3',
                      title: 'Set Rebate',
                      description:
                          'Drag the slider to select your rebate percentage (0% to 5%).',
                    ),
                    _StepRow(
                      step: '4',
                      title: 'Calculate',
                      description:
                          'Tap "Calculate" to see your total charges and final cost after rebate.',
                    ),
                    _StepRow(
                      step: '5',
                      title: 'Save Record',
                      description:
                          'Tap "Save to Database" to store the result for future reference.',
                    ),
                    _StepRow(
                      step: '6',
                      title: 'View History',
                      description:
                          'Tap the history icon (top right) to see all saved records listed by month.',
                    ),
                    _StepRow(
                      step: '7',
                      title: 'Manage Records',
                      description:
                          'Tap any record in the list to view full details, edit, or delete it.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tariff Info
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Tariff Block Information',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor),
                    ),
                    Divider(),
                    Text(
                      'The electricity bill is calculated based on a tiered block system:',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    SizedBox(height: 8),
                    _TariffRow('Block 1: 1 – 200 kWh', '21.8 sen/kWh'),
                    _TariffRow('Block 2: 201 – 300 kWh', '33.4 sen/kWh'),
                    _TariffRow('Block 3: 301 – 600 kWh', '51.6 sen/kWh'),
                    _TariffRow('Block 4: 601 – 1000 kWh', '54.6 sen/kWh'),
                    SizedBox(height: 8),
                    Text(
                      'Formula: Final Cost = Total Charges − (Total Charges × Rebate%)',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  fontSize: 14)),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String step;
  final String title;
  final String description;

  const _StepRow(
      {required this.step, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppTheme.primaryColor,
            child: Text(step,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TariffRow extends StatelessWidget {
  final String block;
  final String rate;

  const _TariffRow(this.block, this.rate);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: AppTheme.accentColor),
          const SizedBox(width: 8),
          Expanded(
              child: Text(block,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 13))),
          Text(rate,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

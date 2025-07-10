import 'package:flutter/material.dart';

class AnalyticsDashboardPage extends StatelessWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildChartCard(
              context,
              icon: Icons.bar_chart,
              title: 'Expired Products',
              subtitle: 'See expired products in detail',
              route: '/analytics/expired-details',
            ),
            const SizedBox(height: 16),
            _buildChartCard(
              context,
              icon: Icons.pie_chart,
              title: 'Inventory Breakdown',
              subtitle: 'Inventory categorized view',
              route: '/analytics/inventory-breakdown',
            ),
            const SizedBox(height: 16),
            _buildChartCard(
              context,
              icon: Icons.show_chart,
              title: 'Restocking Trends',
              subtitle: 'Predicted restocking needs',
              route: '/analytics/restocking-trends',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 28, color: Colors.blueGrey),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text("Chart Placeholder")),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

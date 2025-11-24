import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StrengthPieChart extends StatelessWidget {
  final double currentStrength;
  final double radius;

  const StrengthPieChart({
    super.key,
    required this.currentStrength,
    this.radius = 100,
  });

  @override
  Widget build(BuildContext context) {
    final double decayedStrength = (100.0 - currentStrength).clamp(0.0, 100.0);

    return SizedBox(
      height: radius * 2,
      width: radius * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: radius * 0.6,
              startDegreeOffset: 270,
              sections: [
                // Active Portion
                PieChartSectionData(
                  color: _getStatusColor(currentStrength),
                  value: currentStrength,
                  title: '${currentStrength.round()}%',
                  radius: radius * 0.4, // Thickness
                  titleStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // Decayed Portion
                PieChartSectionData(
                  color: Colors.grey.shade300,
                  value: decayedStrength,
                  title: '',
                  radius: radius * 0.4,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Active',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              Text(
                '${currentStrength.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(currentStrength),
                    ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Color _getStatusColor(double strength) {
    if (strength > 75) return Colors.green;
    if (strength > 40) return Colors.purple;
    if (strength > 20) return Colors.orange;
    return Colors.red;
  }
}


import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/habit.dart';
import '../../../services/decay_service.dart';

class DecayChart extends StatelessWidget {
  final Habit habit;
  final bool isCompact;

  const DecayChart({
    super.key,
    required this.habit,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: isCompact ? 2.0 : 1.70,
      child: LineChart(
        _chartData(context),
      ),
    );
  }

  LineChartData _chartData(BuildContext context) {
    final List<FlSpot> spots = _generateSpots();
    
    return LineChartData(
      gridData: FlGridData(
        show: !isCompact,
        drawVerticalLine: false,
        horizontalInterval: 25,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: !isCompact,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: max(1, (spots.last.x / 5).floorToDouble()),
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  _formatXAxis(value),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 25,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  '${value.toInt()}%',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: spots.last.x,
      minY: 0,
      maxY: 105,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              _getColorForStrength(100),
              _getColorForStrength(50),
              _getColorForStrength(0),
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                _getColorForStrength(100).withOpacity(0.3),
                _getColorForStrength(0).withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: !isCompact,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              return LineTooltipItem(
                '${touchedSpot.y.toStringAsFixed(1)}%',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    final double halfLifeHours = habit.halfLifeSeconds / 3600;
    final double rangeHours = halfLifeHours * 3; 
    
    final List<FlSpot> spots = [];
    const int divisions = 50; 
    
    for (int i = 0; i <= divisions; i++) {
      final double t = (rangeHours / divisions) * i; // Time in hours
      final double elapsedSeconds = t * 3600;
      final double decayFactor = pow(0.5, elapsedSeconds / habit.halfLifeSeconds).toDouble();
      final double projectedStrength = (habit.currentStrength * decayFactor).clamp(0.0, 100.0);
      
      spots.add(FlSpot(t, projectedStrength));
    }
    
    return spots;
  }

  String _formatXAxis(double value) {
    if (value == 0) return 'Start';
    return '${value.toInt()}h';
  }

  Color _getColorForStrength(double strength) {
    if (strength > 75) return Colors.green;
    if (strength > 40) return Colors.purple;
    if (strength > 20) return Colors.orange;
    return Colors.red;
  }
}

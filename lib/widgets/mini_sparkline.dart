import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/chart_service.dart';

/// A tiny inline sparkline chart that shows a simple price trend
class MiniSparkline extends StatelessWidget {
  final String pairId;
  final Color? color;
  final double height;

  const MiniSparkline({
    super.key,
    required this.pairId,
    this.color,
    this.height = 36,
  });

  Future<List<ChartDataPoint>> _loadChartData() async {
    try {
      return await ChartService.instance.getChartData(
        pairId,
        timeframe: '5m',
        limit: 20,
      );
    } catch (e) {
      // Fallback to mock data if API fails
      return _generateMockData();
    }
  }

  List<ChartDataPoint> _generateMockData() {
    final now = DateTime.now();
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final basePrice = 1.0 + (random / 100);
    
    return List.generate(20, (i) {
      final variance = (i % 3 - 1) * 0.02;
      return ChartDataPoint(
        price: basePrice + variance,
        timestamp: now.subtract(Duration(minutes: (20 - i) * 5)),
        volume: 1000 + (i % 5) * 200,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChartDataPoint>>(
      future: _loadChartData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: height,
            width: 60,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }

        final history = snapshot.data!;
        
        // Determine chart color based on price trend
        final isPositive = history.isNotEmpty && 
            history.last.price > history.first.price;
        final chartColor = color ?? (isPositive ? Colors.green : Colors.red);

        return SizedBox(
          height: height,
          width: 60,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              minY: history.map((e) => e.price).reduce((a, b) => a < b ? a : b),
              maxY: history.map((e) => e.price).reduce((a, b) => a > b ? a : b),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (int i = 0; i < history.length; i++)
                      FlSpot(i.toDouble(), history[i].price),
                  ],
                  isCurved: true,
                  color: chartColor,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: chartColor.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

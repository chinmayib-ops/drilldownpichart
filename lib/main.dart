import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() => runApp(MaterialApp(home: Scaffold(body: ChartToggleDemo())));

class ChartToggleDemo extends StatefulWidget {
  @override
  State<ChartToggleDemo> createState() => _ChartToggleDemoState();
}

class _ChartToggleDemoState extends State<ChartToggleDemo> {
  bool showPieChart = true;
  String? selectedCategory;
  bool isDrilled = false;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  // Data
  final List<ChartData> topLevelData = [
    ChartData('Deposit', 51.1, Colors.amber),
    ChartData('Equities', 21, Colors.blue),
    ChartData('Insurance', 48.8, Colors.pink),
    ChartData('GST', 0.1, Colors.red),
  ];

  final Map<String, List<ChartData>> subCategoryData = {
    'Deposit': [
      ChartData('Deposit', 23, Colors.amber),
      ChartData('Term deposit', 17, Colors.amber.shade300),
      ChartData('Recurring deposit', 23, Colors.amber.shade600),
      ChartData('Certificates of deposits', 18, Colors.amber.shade700),
      ChartData('SIP', 2, Colors.amber.shade800),
    ],
    'Equities': [
      ChartData('Equities', 21, Colors.blue),
      ChartData('Mutual funds', 17, Colors.blue.shade300),
      ChartData('Govt. bonds', 0.03, Colors.blue.shade600),
      ChartData('Infrastructure', 20, Colors.blue.shade900),
    ],
    'Insurance': [
      ChartData('Insurance', 48.8, Colors.pink),
    ],
    'GST': [
      ChartData('GST', 0.1, Colors.red),
    ],
  };

  List<ChartData> get currentData =>
      isDrilled && selectedCategory != null
          ? subCategoryData[selectedCategory!] ?? []
          : topLevelData;

  String get chartTitle =>
      isDrilled && selectedCategory != null
          ? '$selectedCategory Breakdown'
          : 'Asset Allocation';

  double get totalAssets =>
      (isDrilled && selectedCategory != null
          ? subCategoryData[selectedCategory!] ?? []
          : topLevelData)
      .fold(0, (sum, item) => sum + item.y);

  void drillDown(String category) {
    if (subCategoryData.containsKey(category)) {
      setState(() {
        selectedCategory = category;
        isDrilled = true;
      });
    }
  }

  void drillUp() {
    setState(() {
      selectedCategory = null;
      isDrilled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Toggle Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => showPieChart = true),
                child: const Text('Pie Chart'),
                style: TextButton.styleFrom(
                  foregroundColor: showPieChart ? Colors.blue : Colors.grey,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => showPieChart = false),
                child: const Text('Asset Chart'),
                style: TextButton.styleFrom(
                  foregroundColor: !showPieChart ? Colors.blue : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            chartTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: showPieChart
                ? _buildPieChart()
                : _buildBarChart(),
          ),
          if (isDrilled)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextButton.icon(
                onPressed: drillUp,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return SfCircularChart(
      annotations: <CircularChartAnnotation>[
        CircularChartAnnotation(
          widget: Text(
            'Total\n${totalAssets.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
      tooltipBehavior: _tooltipBehavior,
      legend: Legend(isVisible: true),
      series: <DoughnutSeries<ChartData, String>>[
        DoughnutSeries<ChartData, String>(
          dataSource: currentData,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          pointColorMapper: (ChartData data, _) => data.color,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: TextStyle(fontSize: 12),
          ),
          enableTooltip: true,
          explode: true,
          onPointTap: (ChartPointDetails details) {
            if (!isDrilled) {
              final tapped = currentData[details.pointIndex!].x;
              drillDown(tapped);
            }
          },
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return Column(
      children: [
        Text(
          'Total: ${totalAssets.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SfCartesianChart(
              tooltipBehavior: _tooltipBehavior,
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(fontSize: 12),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: 100,
                interval: 10,
                labelFormat: '{value}%',
                labelStyle: const TextStyle(fontSize: 12),
              ),
              series: <BarSeries<ChartData, String>>[
                BarSeries<ChartData, String>(
                  dataSource: currentData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  pointColorMapper: (ChartData data, _) => data.color,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  borderRadius: BorderRadius.circular(6),
                  width: 0.6,
                  onPointTap: (ChartPointDetails details) {
                    if (!isDrilled) {
                      final tapped = currentData[details.pointIndex!].x;
                      drillDown(tapped);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}

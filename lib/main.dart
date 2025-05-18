import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() => runApp(MaterialApp(home: Scaffold(body: DrillDownChart())));

class DrillDownChart extends StatefulWidget {
  @override
  _DrillDownChartState createState() => _DrillDownChartState();
}

class _DrillDownChartState extends State<DrillDownChart> {
  late List<ChartData> _chartData;
  late List<ChartData> _subCategoryData;
  late TooltipBehavior _tooltipBehavior;
  String? _selectedCategory;
  bool _isDrilled = false;

  @override
  void initState() {
    _chartData = getChartData();
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Text(
            _isDrilled ? '$_selectedCategory Details' : 'Asset Classes',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SfCircularChart(
              title: ChartTitle(
                text: _isDrilled ? '$_selectedCategory Breakdown' : 'Asset Distribution',
                textStyle: const TextStyle(fontSize: 16),
              ),
              legend: Legend(isVisible: true),
              tooltipBehavior: _tooltipBehavior,
              series: <CircularSeries>[
                DoughnutSeries<ChartData, String>(
                  dataSource: _isDrilled ? _subCategoryData : _chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(fontSize: 12),
                  ),
                  enableTooltip: true,
                  pointColorMapper: (ChartData data, _) => data.color,
                  explode: true,
                  explodeIndex: _isDrilled ? 0 : null,
                  onPointTap: (ChartPointDetails details) {
                    if (!_isDrilled) {
                      final category = _chartData[details.pointIndex!].x;
                      setState(() {
                        _selectedCategory = category;
                        _subCategoryData = getSubCategoryData(category);
                        _isDrilled = true;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          if (_isDrilled)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isDrilled = false;
                    _selectedCategory = null;
                  });
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Asset Classes'),
              ),
            ),
        ],
      ),
    );
  }

  List<ChartData> getChartData() {
    return <ChartData>[
      ChartData('Deposit', 51.1, Colors.amber),
      ChartData('Equities', 0.0, Colors.blue),
      ChartData('Insurance', 48.8, Colors.pink),
      ChartData('GST', 0.1, Colors.red),
    ];
  }

  List<ChartData> getSubCategoryData(String category) {
    switch (category) {
      case 'Deposit':
        return <ChartData>[
          ChartData('Deposit', 25.0, Colors.amber),
          ChartData('Term deposit', 15.0, Colors.amber.shade300),
          ChartData('Recurring deposit', 11.1, Colors.amber.shade600),
        ];
      case 'Equities':
        return <ChartData>[
          ChartData('Equities', 0.0, Colors.blue),
          ChartData('ETF', 0.0, Colors.blue.shade300),
          ChartData('Mutual funds', 0.0, Colors.blue.shade600),
          ChartData('Govt. bonds', 0.0, Colors.blue.shade900),
          ChartData('Bonds', 0.0, Colors.blue.shade700),
          ChartData('Debentures', 0.0, Colors.blue.shade500),
        ];
      case 'Insurance':
        return <ChartData>[
          ChartData('Insurance', 48.8, Colors.pink),
        ];
      case 'GST':
        return <ChartData>[
          ChartData('GST', 0.1, Colors.red),
        ];
      default:
        return <ChartData>[];
    }
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color color;
}

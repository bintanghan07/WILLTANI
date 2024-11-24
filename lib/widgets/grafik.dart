import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webagro/chopper_api/api_client.dart';
import 'package:webagro/models/grafik.dart';
import 'package:webagro/models/greenhouse.dart';
import 'package:webagro/utils/responsiveLayout.dart';
import 'package:webagro/widgets/custom_appbar.dart';

class Grafik extends StatefulWidget {
  const Grafik({super.key});

  @override
  _GrafikState createState() => _GrafikState();
}

class _GrafikState extends State<Grafik> {
  String? token;
  int selectedGreenhouse = 0;
  Timer? timer;

  final apiService = ApiClient().apiService;

  List<GreenhouseM> greenhouses = [];
  List<dynamic>? latestGraphData;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _getToken();
    if (token != null) {
      await _fetchGreenhouses();
    }
  }

  void _startFetchingSensorData() {
    timer = Timer.periodic(const Duration(seconds: 30), (Timer t) {
      _fetchLatestSensor();
    });
  }

  Future<void> _fetchLatestSensor() async {
    final response = await apiService.getGraphSensorData(
        'Bearer $token', selectedGreenhouse); // Pass the token
    if (response.isSuccessful) {
      final graphData = response.body["data"];
      if (graphData != null) {
        setState(() {
          latestGraphData =
              graphData.map((graph) => GrafikM.fromJson(graph)).toList();
        });
      }
    } else {
      print('Failed to fetch sensor data: ${response.error}');
    }
  }

  Future<void> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('bearer_token');
    setState(() {
      this.token = token;
    });
  }

  Future<void> _fetchGreenhouses() async {
    final response =
        await apiService.getAllGreenhouses('Bearer $token'); // Pass the token

    if (response.isSuccessful) {
      setState(() {
        greenhouses = (response.body["data"] as List)
            .map((greenhouse) => GreenhouseM.fromJson(greenhouse))
            .toList();
      });
    } else {
      // Handle error
      print('Failed to fetch greenhouses: ${response.error}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        activityName: "Grafik",
      ),
      body: ResponsiveLayout(
        largeScreen: _buildContent(4), // 2 kolom untuk layar besar
        smallScreen: _buildContent(1), // 1 kolom untuk layar kecil
      ),
    );
  }

  Widget _buildContent(int crossAxisCount) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButton<int>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  hint: Text(
                    "Pilih Greenhouse ~",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  value: selectedGreenhouse > 0 ? selectedGreenhouse : null,
                  items: greenhouses.map((GreenhouseM greenhouse) {
                    return DropdownMenuItem<int>(
                      value: greenhouse.id,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.eco,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            greenhouse.nama,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedGreenhouse = newValue!;
                    });
                    _fetchLatestSensor();
                    _startFetchingSensorData();
                  },
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                ),
              ),
            ),
          ),
          if (selectedGreenhouse != 0)
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width:
                  MediaQuery.of(context).size.width, // Adjust width as needed
              child: GridView.count(
                crossAxisCount: crossAxisCount,
                children: [
                  _buildGraphCard('Grafik Suhu', latestGraphData?[0]),
                  _buildGraphCard('Grafik Kelembaban', latestGraphData?[1]),
                  _buildGraphCard('Grafik Debit Air', latestGraphData?[2]),
                  _buildGraphCard('Grafik TDS', latestGraphData?[3]),
                ],
              ),
            ),
          if (selectedGreenhouse == 0)
            const Center(
              child: Text('Silakan pilih Greenhouse untuk melihat grafik.'),
            ),
        ],
      ),
    );
  }

  Widget _buildGraphCard(String title, GrafikM? latestGraphData) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 18, top: 12),
              // Pass the latestGraphData to the chart function
              child: LineChart(chart(latestGraphData)),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData chart(GrafikM? latestGraphData) {
    if (latestGraphData == null || latestGraphData.data.isEmpty) {
      return LineChartData(
        lineBarsData: [],
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
      );
    }

    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              // Ensure index is within bounds of the labels array
              if (index >= 0 && index < latestGraphData.labels.length) {
                return RotatedBox(
                  quarterTurns: 3, // Rotates the text vertically
                  child: Text(
                    latestGraphData.labels[index],
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox
                  .shrink(); // Return empty if index out of range
            },
            interval: 1, // Show labels at every point
            reservedSize: 80, // Adjust this for spacing of labels
          ),
        ),
      ),
      borderData: FlBorderData(show: true),
      minX: 0,
      maxX: latestGraphData.data.length - 1,
      minY: 0,
      maxY: latestGraphData.data.reduce((a, b) => a > b ? a : b) + 5,
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            latestGraphData.data.length,
            (index) => FlSpot(index.toDouble(), latestGraphData.data[index]),
          ),
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }
}

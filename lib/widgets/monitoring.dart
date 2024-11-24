import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webagro/chopper_api/api_client.dart';
import 'package:webagro/models/greenhouse.dart';
import 'package:webagro/models/sensor.dart';
import 'package:webagro/widgets/custom_appbar.dart';
import 'package:webagro/utils/responsiveLayout.dart';

class Monitoring extends StatefulWidget {
  const Monitoring({super.key});

  @override
  _MonitoringState createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {
  String? token;
  int selectedGreenhouse = 0;
  Timer? timer;

  final apiService = ApiClient().apiService;

  List<GreenhouseM> greenhouses = [];
  List<dynamic>? latestSensorData;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _getToken(); // Wait for token retrieval
    if (token != null) {
      await _fetchGreenhouses(); // Only fetch greenhouses if token is set
    }
  }

  void _startFetchingSensorData() {
    // This method will start a timer that calls _fetchLatestSensor every 30 seconds (or any interval you want)
    timer = Timer.periodic(const Duration(seconds: 30), (Timer t) {
      _fetchLatestSensor(); // Call your function to fetch the latest sensor data
    });
  }

  Future<void> _fetchLatestSensor() async {
    final response = await apiService.getLatestSensorData(
        'Bearer $token', selectedGreenhouse); // Pass the token

    if (response.isSuccessful) {
      final sensorData = response.body["data"]["sensor"]["perangkat"]["sensor"];
      if (sensorData != null) {
        setState(() {
          latestSensorData = sensorData;
        });
      }
    } else {
      SnackBar(content: Text('Failed to fetch sensor data: ${response.error}'));
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
        activityName: "Monitoring",
      ),
      body: ResponsiveLayout(
        largeScreen: _buildContent(),
        smallScreen: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 600;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildDropdown(),
          const SizedBox(height: 20),
          if (selectedGreenhouse == 0)
            const Center(
              child: Text(
                  'Silakan pilih Greenhouse untuk melihat data monitoring.'),
            )
          else
            Expanded(
                child: latestSensorData == null
                    ? const Center(
                        child:
                            CircularProgressIndicator()) // Show loading indicator if sensor data is still being fetched
                    : isLargeScreen
                        ? _buildDataTable()
                        : _buildDataList()),
        ],
      ),
    );
  }

  Widget _buildDataList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: latestSensorData!.length,
      itemBuilder: (context, index) {
        final item = Sensor.fromJson(latestSensorData![index]);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Perangkat ${item.perangkatId}'),
                    Text(
                      DateFormat('dd-MM-yyyy HH:mm:ss').format(item.createdAt),
                    ),
                  ],
                ),

                // bagian iki perlu ditata sih.. konsul o pak dim
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoTile(
                        Icons.water_damage, "${item.sensorKelembaban}%"),
                    _buildInfoTile(Icons.thermostat, "${item.sensorSuhu}°"),
                    _buildInfoTile(Icons.wb_sunny, "${item.sensorLdr} lux")
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // gangerti satuan e debit air
                    _buildInfoTile(
                        Icons.water_outlined, "${item.sensorWaterflow}"),
                    _buildInfoTile(Icons.grain, "${item.sensorTds} ppm"),
                    _buildInfoTile(Icons.waves, "${item.sensorVolume} L"),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTile(IconData icon, String value) {
    return Card(
      color: const Color.fromARGB(
          255, 255, 255, 255), // Warna latar belakang ungu terang
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Sudut yang membulat
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.0, color: Colors.black),
            const SizedBox(
              width: 2,
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black, // Warna teks hitam untuk label
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DecoratedBox(
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
            "Pilih Greenhouse",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          value: selectedGreenhouse != 0 ? selectedGreenhouse : null,
          items: greenhouses.map((GreenhouseM value) {
            return DropdownMenuItem<int>(
              value: value.id,
              child: Row(
                children: [
                  const Icon(
                    Icons.eco,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value.nama,
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
    );
  }

  Widget _buildDataTable() {
    return DataTable(
        columns: const [
          DataColumn(label: Text('Perangkat')),
          DataColumn(label: Text('Tanggal')),
          DataColumn(label: Text('Kelembaban')),
          DataColumn(label: Text('Suhu')),
          DataColumn(label: Text('Intensitas Cahaya')),
          DataColumn(label: Text('Debit Air')),
          DataColumn(label: Text('TDS')),
          DataColumn(label: Text('Volume Air')),
        ],
        rows: latestSensorData!
            .asMap()
            .entries
            .map(
              (entry) => DataRow(cells: [
                DataCell(Text('Perangkat ${entry.value['perangkat_id']!}')),
                DataCell(Text(DateFormat('dd-MM-yyyy HH:mm:ss')
                    .format(DateTime.parse(entry.value['created_at']!)))),
                DataCell(Text(entry.value['sensor_kelembaban']!)),
                DataCell(Text(entry.value['sensor_suhu']!)),
                DataCell(Text(entry.value['sensor_ldr']!)),
                DataCell(Text(entry.value['sensor_waterflow']!)),
                DataCell(Text(entry.value['sensor_tds']!)),
                DataCell(Text(entry.value['sensor_volume']!)),
              ]),
            )
            .toList());
  }
}

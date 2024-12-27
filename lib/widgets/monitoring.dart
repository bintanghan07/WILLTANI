import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webagro/chopper_api/api_client.dart';
import 'package:webagro/models/greenhouse.dart';
import 'package:webagro/models/sensor.dart';
import 'package:webagro/widgets/custom_appbar.dart';

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
    final response = await apiService.getLatestSensorData(
        'Bearer $token', selectedGreenhouse); 

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
    final response = await apiService.getAllGreenhouses('Bearer $token'); 

    if (response.isSuccessful) {
      setState(() {
        greenhouses = (response.body["data"] as List)
            .map((greenhouse) => GreenhouseM.fromJson(greenhouse))
            .toList();
      });
    } else {
      print('Failed to fetch greenhouses: ${response.error}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        activityName: "Monitoring",
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isLargeScreen = constraints.maxWidth > 800; 
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView( 
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
                    Container(
                      child: latestSensorData == null
                          ? const Center(child: CircularProgressIndicator())
                          : isLargeScreen
                              ? _buildDataTable() 
                              : _buildDataList(), 
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataList() {
    return ListView.builder(
      shrinkWrap: true, 
      physics: const BouncingScrollPhysics(), 
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
                    Text('Perangkat ${item.perangkatId?.toString() ?? 'N/A'}'),
                    Text(DateFormat('dd-MM-yyyy HH:mm:ss').format(item.createdAt ?? DateTime.now())),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoTile(Icons.water_damage, "${item.sensorKelembaban?.toString() ?? 'N/A'}%"),
                    _buildInfoTile(Icons.thermostat, "${item.sensorSuhu?.toString() ?? 'N/A'}°"),
                    _buildInfoTile(Icons.wb_sunny, "${item.sensorLdr?.toString() ?? 'N/A'} lux")
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoTile(Icons.water_outlined, "${item.sensorWaterflow?.toString() ?? 'N/A'}"),
                    _buildInfoTile(Icons.grain, "${item.sensorTds?.toString() ?? 'N/A'} ppm"),
                    _buildInfoTile(Icons.waves, "${item.sensorVolume?.toString() ?? 'N/A'} L"),
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
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.0, color: Colors.black),
            const SizedBox(width: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
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
                  const Icon(Icons.eco, color: Colors.green),
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
              DataCell(Text('Perangkat ${entry.value['perangkat_id']?.toString() ?? 'N/A'}')),
              DataCell(Text(DateFormat('dd-MM-yyyy HH:mm:ss')
                  .format(DateTime.parse(entry.value['created_at'] ?? '1970-01-01T00:00:00')))),
              DataCell(Text(entry.value['sensor_kelembaban']?.toString() ?? 'N/A')),
              DataCell(Text(entry.value['sensor_suhu']?.toString() ?? 'N/A')),
              DataCell(Text(entry.value['sensor_ldr']?.toString() ?? 'N/A')),
              DataCell(Text(entry.value['sensor_waterflow']?.toString() ?? 'N/A')),
              DataCell(Text(entry.value['sensor_tds']?.toString() ?? 'N/A')),
              DataCell(Text(entry.value['sensor_volume']?.toString() ?? 'N/A')),
            ]), 
          )
          .toList(),
    );
  }
}

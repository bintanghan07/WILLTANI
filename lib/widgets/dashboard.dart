import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webagro/chopper_api/api_client.dart';
import 'package:webagro/models/sensor.dart';
import 'package:webagro/widgets/custom_appbar.dart';
import 'package:webagro/models/greenhouse.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? token;
  int selectedGreenhouse = 0;
  Timer? timer;

  final apiService = ApiClient().apiService;

  List<GreenhouseM> greenhouses = [];
  Sensor? latestSensorData;

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
        'Bearer $token', selectedGreenhouse); // Pass the token

    if (response.isSuccessful) {
      final sensorData = response.body["data"]["sensor"];
      if (sensorData != null) {
        setState(() {
          latestSensorData = Sensor.fromJson(sensorData);
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
        activityName: "Dashboard",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.green),
                  ),
                ),
              ),
            ),
            if (selectedGreenhouse == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text(
                    'Silakan pilih Greenhouse untuk melihat Kontrol.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
              )
            else
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      return Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: latestSensorData == null
                                ? const Center(
                                    child:
                                        CircularProgressIndicator()) // Show loading indicator if sensor data is still being fetched
                                : GridView.count(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 8.0,
                                    crossAxisSpacing: 8.0,
                                    childAspectRatio: 1.3,
                                    children: [
                                      _buildInfoTile(Icons.thermostat,
                                          latestSensorData!.sensorSuhu, 'SUHU'),
                                      _buildInfoTile(
                                          Icons.wb_sunny_outlined,
                                          latestSensorData!.sensorLdr,
                                          'INT CAHAYA'),
                                      _buildInfoTile(
                                          Icons.water_damage,
                                          '${latestSensorData!.sensorKelembaban}%',
                                          'KELEMBABAN'),
                                      _buildInfoTile(
                                          Icons.water_outlined,
                                          '${latestSensorData!.sensorWaterflow}L',
                                          'DEBIT AIR'),
                                      _buildInfoTile(Icons.grain,
                                          latestSensorData!.sensorTds, 'TDS'),
                                      _buildInfoTile(
                                          Icons.waves,
                                          latestSensorData!.sensorVolume,
                                          'VOLUME'),
                                    ],
                                  ),
                          ),
                          const SizedBox(
                              width: 16.0),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: _buildGridItem(
                                      'NOTIFIKASI',
                                      Icons.notifications,
                                      const Color(0xFFF7F4FD),
                                      notificationCount: 1),
                                ),
                                const SizedBox(height: 16.0),
                                Expanded(
                                  flex: 1,
                                  child: latestSensorData == null
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : _buildImageTile(
                                          greenhouses[selectedGreenhouse]
                                              .gambar),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: _buildGridItem(
                                      'NOTIFIKASI',
                                      Icons.notifications,
                                      const Color(0xFFF7F4FD),
                                      notificationCount: 1),
                                ),
                                const SizedBox(height: 16.0),
                                Expanded(
                                  flex: 1,
                                  child: latestSensorData == null
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : _buildImageTile(
                                          greenhouses[selectedGreenhouse - 1]
                                              .gambar),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                              height:
                                  16.0), 
                          Expanded(
                            flex: 3,
                            child: latestSensorData == null
                                ? const Center(
                                    child:
                                        CircularProgressIndicator()) 
                                : GridView.count(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 8.0,
                                    crossAxisSpacing: 8.0,
                                    childAspectRatio: 1.2,
                                    children: [
                                      _buildInfoTile(Icons.thermostat,
                                          latestSensorData!.sensorSuhu, 'SUHU'),
                                      _buildInfoTile(
                                          Icons.wb_sunny_outlined,
                                          latestSensorData!.sensorLdr,
                                          'INT CAHAYA'),
                                      _buildInfoTile(
                                          Icons.water_damage,
                                          '${latestSensorData!.sensorKelembaban}%',
                                          'KELEMBABAN'),
                                      _buildInfoTile(
                                          Icons.water_outlined,
                                          '${latestSensorData!.sensorWaterflow}L',
                                          'DEBIT AIR'),
                                      _buildInfoTile(Icons.grain,
                                          latestSensorData!.sensorTds, 'TDS'),
                                      _buildInfoTile(
                                          Icons.waves,
                                          latestSensorData!.sensorVolume,
                                          'VOLUME'),
                                    ],
                                  ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String value, String label) {
    return Card(
      color: const Color(0xFFF7F4FD), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40.0, color: Colors.black), 
            const SizedBox(height: 8.0),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black, 
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
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

  Widget _buildGridItem(String title, IconData icon, Color color,
      {int notificationCount = 0}) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), 
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.black, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Stack(
                  children: [
                    Icon(icon,
                        size: 30.0, color: Colors.black), 
                    if (notificationCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.red,
                          child: Text(
                            '$notificationCount',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Subtitle',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black, 
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(String gambar) {
    String baseUrl = "https://apiv2.willtani.id/public/uploads/greenhouse/";
    return Card(
      color: const Color(0xFFF7F4FD), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), 
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.network(
                "$baseUrl$gambar",
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

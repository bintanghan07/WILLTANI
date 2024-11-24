import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webagro/chopper_api/api_client.dart';
import 'package:webagro/models/greenhouse.dart';
import 'package:webagro/models/pompa.dart';
import 'package:webagro/models/sensor.dart';
import 'package:webagro/models/kontrol.dart';
import 'package:webagro/widgets/custom_appbar.dart';
import 'package:webagro/utils/responsiveLayout.dart';
import 'package:webagro/widgets/edit_settings.dart';

class Kontrol extends StatefulWidget {
  const Kontrol({super.key});

  @override
  _KontrolState createState() => _KontrolState();
}

class _KontrolState extends State<Kontrol> {
  String? manualSaklar;
  String? automaticMode;

  bool isManualSaklar = false;
  bool isAutomaticMode = false;

  String? token;
  int selectedGreenhouse = 0;
  Timer? timer;

  final apiService = ApiClient().apiService;

  List<GreenhouseM> greenhouses = [];
  Sensor? latestSensorData;
  KontrolM? latestKontrolData;

  // Variabel untuk menyimpan pilihan greenhouse

  // Variabel yang akan menyimpan nilai setting

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
      final sensorData = response.body["data"]["sensor"];
      if (sensorData != null) {
        setState(() {
          latestSensorData = Sensor.fromJson(sensorData);
        });
        _fetchLatestPompa();
        _fetchLatestKontrol();
      }
    } else {
      print('Failed to fetch sensor data: ${response.error}');
    }
  }

  Future<void> _fetchLatestPompa() async {
    final response = await apiService.getLatestPompaData('Bearer $token',
        int.parse(latestSensorData!.perangkatId)); // Pass the token

    if (response.isSuccessful) {
      final pompaData = response.body['data'];
      if (pompaData != null) {
        setState(() {
          automaticMode = Pompa.fromJson(pompaData).auto;
          manualSaklar = Pompa.fromJson(pompaData).status;

          isAutomaticMode =
              Pompa.fromJson(pompaData).auto == "HIDUP" ? true : false;
          isManualSaklar =
              Pompa.fromJson(pompaData).status == "HIDUP" ? true : false;
        });
      }
    } else {
      print('Failed to fetch sensor data: ${response.error}');
    }
  }

  Future<void> _fetchLatestKontrol() async {
    final response = await apiService.getKontrolData('Bearer $token',
        int.parse(latestSensorData!.perangkatId)); // Pass the token

    if (response.isSuccessful) {
      final kontrolData = KontrolM.fromJson(response.body['data']);
      setState(() {
        latestKontrolData = kontrolData;
      });
    } else {
      print('Failed to fetch sensor data: ${response.error}');
    }
  }

  Future<void> _updatePompa(String status, String auto, int idPerangkat) async {
    var body = {
      "status": status,
      "auto": auto,
      "keterangan": "update",
      "perangkat_id": idPerangkat
    };
    final response = await apiService.updatePompa('Bearer $token',
        int.parse(latestSensorData!.perangkatId), body); // Pass the token

    if (response.isSuccessful) {
      final sensorData = response.body["data"];
      if (sensorData != null) {
        //TODO : idk
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
        activityName: "Kontrol",
      ),
      body: ResponsiveLayout(
        largeScreen: _buildContent(4), // 4 kolom untuk layar besar
        smallScreen: _buildContent(2), // 2 kolom untuk layar kecil
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
            ),
          ),
          if (selectedGreenhouse == 0)
            const Center(
              child: Text('Silakan pilih Greenhouse untuk melihat Kontrol.'),
            ),
          if (selectedGreenhouse > 0) ...[
            // Konten lainnya hanya ditampilkan jika greenhouse sudah dipilih
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: latestSensorData == null
                  ? const Center(child: CircularProgressIndicator())
                  : _buildImageTile(greenhouses[selectedGreenhouse - 1].gambar),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch(
                  value: isAutomaticMode,
                  onChanged: (value) {
                    setState(() {
                      isAutomaticMode = value; // Update the automatic mode
                      isManualSaklar =
                          !value; // Set manual switch off if automatic is on
                      automaticMode =
                          value ? "HIDUP" : "MATI"; // Update status for API
                      manualSaklar = isManualSaklar
                          ? "HIDUP"
                          : "MATI"; // Update manual status for API
                    });
                    if (latestSensorData != null) {
                      _updatePompa(manualSaklar!, automaticMode!,
                          int.parse(latestSensorData!.perangkatId));
                    } else {
                      // Handle case where latestSensorData is null, e.g., show a message
                      print('Sensor data is not yet available. Please wait.');
                    }
                  },
                ),
                const Text('Mode Otomatis'),
                const SizedBox(width: 16),
                Switch(
                  value: isManualSaklar,
                  onChanged: (value) {
                    if (!isAutomaticMode) {
                      // Allow change only if automatic mode is off
                      setState(() {
                        isManualSaklar = value; // Update the manual switch
                        manualSaklar = value
                            ? "HIDUP"
                            : "MATI"; // Update manual status for API
                      });
                      if (latestSensorData != null) {
                        _updatePompa(manualSaklar!, automaticMode!,
                            int.parse(latestSensorData!.perangkatId));
                      } else {
                        // Handle case where latestSensorData is null, e.g., show a message
                        print('Sensor data is not yet available. Please wait.');
                      }
                    }
                  },
                ),
                const Text('Saklar Manual'),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: latestSensorData == null
                  ? const Center(
                      child:
                          CircularProgressIndicator()) // Show loading indicator if sensor data is still being fetched
                  : GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 1.0,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildInfoTile(Icons.thermostat,
                            latestSensorData!.sensorSuhu, 'SUHU'),
                        _buildInfoTile(Icons.wb_sunny_outlined,
                            latestSensorData!.sensorLdr, 'INT CAHAYA'),
                        _buildInfoTile(
                            Icons.water_damage,
                            '${latestSensorData!.sensorKelembaban}%',
                            'KELEMBABAN'),
                        _buildInfoTile(
                            Icons.water_outlined,
                            '${latestSensorData!.sensorWaterflow}L',
                            'DEBIT AIR'),
                      ],
                    ),
            ),
            // Kotak untuk pengaturan
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: latestKontrolData == null
                      ? const Center(
                          child:
                              CircularProgressIndicator()) // Show loading indicator if sensor data is still being fetched
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'SETTING',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    if (latestKontrolData != null &&
                                        token != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditSettings(
                                            kontrolM: latestKontrolData!,
                                            token: token!,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.settings),
                                  tooltip: "Edit",
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildSettingItem('Suhu Minimal',
                                latestKontrolData!.suhuMin.toString()),
                            _buildSettingItem('Suhu Maximal',
                                latestKontrolData!.suhuMax.toString()),
                            _buildSettingItem('TDS Minimal',
                                latestKontrolData!.tdsMin.toString()),
                            _buildSettingItem('TDS Maximal',
                                latestKontrolData!.tdsMax.toString()),
                            _buildSettingItem('Kelembaban Minimal',
                                latestKontrolData!.kelembabanMin.toString()),
                            _buildSettingItem('Kelembaban Maximal',
                                latestKontrolData!.kelembabanMax.toString()),
                            _buildSettingItem('Volume Air Minimal',
                                latestKontrolData!.volumeMin.toString()),
                            _buildSettingItem('Volume Air Maximal',
                                latestKontrolData!.volumeMax.toString()),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageTile(String gambar) {
    String baseUrl = "https://apiv2.willtani.id/public/uploads/greenhouse/";
    return Card(
      color: const Color(0xFFF7F4FD), // Warna latar belakang ungu terang
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // Sudut yang membulat
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(16.0), // Sudut yang membulat
              child: AspectRatio(
                aspectRatio: 3 / 1, // Adjust the aspect ratio as needed
                child: Image.network(
                  "$baseUrl$gambar",
                  fit: BoxFit.cover,
                  width: double.infinity, // Match the parent's width
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String value, String label) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value),
        ],
      ),
    );
  }
}

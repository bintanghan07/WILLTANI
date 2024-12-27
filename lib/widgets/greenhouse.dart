import 'dart:convert';
import 'dart:io';
import 'package:chopper/chopper.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webagro/chopper_api/api_client.dart';
import 'package:webagro/models/greenhouse.dart';
import 'package:webagro/models/perangkat.dart';
import 'package:webagro/models/jenistanaman.dart'
    as jenistanaman; 
import 'package:webagro/widgets/custom_appbar.dart';
import 'package:webagro/widgets/edit_greenhouse.dart';
import 'package:webagro/widgets/edit_perangkat.dart';
import 'package:webagro/widgets/tambah_greenhouse.dart';
import 'package:webagro/widgets/tambah_perangkat.dart';

class Greenhouse extends StatefulWidget {
  const Greenhouse({super.key});

  @override
  _GreenhouseState createState() => _GreenhouseState();
}

class _GreenhouseState extends State<Greenhouse> {
  List<GreenhouseM> greenhouses = [];
  List<Perangkat> perangkatModel = [];

  String? token;

  final apiService = ApiClient().apiService;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _getToken();
    if (token != null) {
      await _fetchData();
    }
  }

  Future<void> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('bearer_token');
    });
  }

  Future<void> _fetchData() async {
    await Future.wait([
      _fetchGreenhouses(),
      _fetchAllPerangkat(),
    ]);
  }

  Future<void> _fetchGreenhouses() async {
    setState(() {
      greenhouses = [];
    });
    final response = await apiService.getAllGreenhouses('Bearer $token');

    if (response.isSuccessful) {
      setState(() {
        greenhouses = (response.body["data"] as List)
            .map((greenhouse) => GreenhouseM.fromJson(greenhouse))
            .toList();
      });
    } else {
      _handleError('Failed to fetch greenhouses: ${response.error}');
    }
  }

  Future<void> _fetchAllPerangkat() async {
    final response = await apiService.getAllPerangkat('Bearer $token');

    if (response.isSuccessful) {
      setState(() {
        perangkatModel = (response.body["data"] as List)
            .map((perangkat) => Perangkat.fromJson(perangkat))
            .toList();
      });
    } else {
      _handleError('Failed to fetch perangkat: ${response.error}');
    }
  }

  Future<void> _deleteGreenhouse(int id) async {
    final response = await apiService.deleteGreenhouse('Bearer $token', id);
    print(response);
    _fetchData();
  }

  Future<void> _deletePerangkat(int id) async {
    final response = await apiService.deletePerangkat('Bearer $token', id);
    print(response);
    _fetchData();
  }

  void _handleError(String message) {
    print(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(activityName: "Greenhouse"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(constraints.maxWidth),
                  const SizedBox(height: 20),
                  _buildTableSection(
                    title: 'GreenHouse',
                    table: _buildGreenHouseTable(constraints.maxWidth),
                    addItemWidget: TambahGreenhouse(),
                    onAddItem: _addGreenhouse,
                  ),
                  const SizedBox(height: 20),
                  _buildTableSection(
                    title: 'Perangkat',
                    table: _buildPerangkatTable(constraints.maxWidth),
                    addItemWidget: Tambah_perangkat(greenhouses: greenhouses),
                    onAddItem: _addPerangkat,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildSummaryCard(greenhouses.length.toString(), 'Jumlah Green House'),
        SizedBox(width: width * 0.05),
        _buildSummaryCard(perangkatModel.length.toString(), 'Jumlah Perangkat'),
      ],
    );
  }

  Widget _buildSummaryCard(String number, String label) {
    return Flexible(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFBAC6CB),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              decoration: const BoxDecoration(
                color: Color(0xFF33697C),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF33697C),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableSection({
    required String title,
    required Widget table,
    required Widget addItemWidget,
    required Future<void> Function(Map<String, String>) onAddItem,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tabel $title',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF33697C),
          ),
        ),
        const SizedBox(height: 10),
        _buildTableContainer(
          Column(
            children: [
              _buildSearchAndAddRow(context, addItemWidget, onAddItem),
              const SizedBox(height: 10),
              table,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndAddRow(
    BuildContext context,
    Widget destination,
    Future<void> Function(Map<String, String>) onAddItem,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            width: 200, // Adjust the width as needed
            padding: const EdgeInsets.only(
              left: 8.0,
              top: 8,
            ), // Add padding to not stick to the sides
            child: TextField(
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                hintText: 'Cari',
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal:
                        10.0), // Add horizontal padding to start text not at the very left
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        8)), // Adjust border radius as needed
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 8, bottom: 8),
          child: ElevatedButton(
            onPressed: () async {
              final newItem = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destination),
              );
              if (newItem != null) {
                _fetchData();
                final filteredNewItem = newItem
                    .map((key, value) => MapEntry(key, value ?? ''))
                    .cast<String, String>();
                onAddItem(filteredNewItem);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF33697C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Tambah'),
          ),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }

  Future<void> _addGreenhouse(Map<String, dynamic> newGreenhouse) async {}

  Future<void> _addPerangkat(Map<String, String> newDevice) async {
    final data = Perangkat(
      id: perangkatModel.length,
      nama: newDevice['name'] ?? "",
      keterangan: newDevice['description'] ?? "",
      greenhouseId: "${newDevice['greenhouse_id']}",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    var response =
        await apiService.createPerangkat('Bearer $token', data.toJson());
    print(response);
    _fetchAllPerangkat();
  }

  Future<void> _editPerangkat(Map<String, String> newDevice) async {
    print("RIZQI");
    var id = int.parse(newDevice['id'] ?? "0");
    final data = Perangkat(
      id: id,
      nama: newDevice['name'] ?? "",
      keterangan: newDevice['description'] ?? "",
      greenhouseId: "${newDevice['greenhouse_id']}",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    var response =
        await apiService.updatePerangkat('Bearer $token', id, data.toJson());
    print(response);
    _fetchAllPerangkat();
  }

  Widget _buildGreenHouseTable(double width) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: _buildDataTable(
        columns: [
          'Nama',
          'Pemilik',
          'Pengelola',
          'Alamat',
          'Ukuran',
          'Jenis Tanaman',
          'Telegram ID',
          'Aksi'
        ],
        rows: greenhouses.map((greenhouse) {
          return _buildGreenHouseRow(greenhouse, context);
        }).toList(),
      ),
    );
  }

  DataRow _buildGreenHouseRow(GreenhouseM greenhouse, BuildContext context) {
    return DataRow(
      color: MaterialStateProperty.all(Colors.white),
      cells: [
        DataCell(Text(greenhouse.nama ?? '')),
        DataCell(Text(greenhouse.pemilik ?? '')),
        DataCell(Text(greenhouse.pengelola ?? '')),
        DataCell(Text(greenhouse.alamat ?? '')),
        DataCell(Text(greenhouse.ukuran ?? '')),
        DataCell(Text(greenhouse.jenisTanaman?.nama ?? '')),
        DataCell(Text(greenhouse.telegramId ?? '')),
        DataCell(
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TambahGreenhouse(
                        key: Key(greenhouse.id.toString()),
                        greenhouse: greenhouse,
                      ),
                    ),
                  );
                  _fetchGreenhouses(); 
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () async {
                  bool? confirmDelete = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Anda Yakin?"),
                        content: const Text(
                            "Apakah Anda yakin ingin menghapus item ini?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(false); 
                            },
                            child: const Text("No"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(true); 
                            },
                            child: const Text("Yes"),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmDelete == true) {
                    _deleteGreenhouse(greenhouse.id);
                  }
                },
                icon: const Icon(Icons.delete),
                color: Colors.red,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerangkatTable(double width) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _buildDataTable(
          columns: ['Nama', 'Keterangan', 'Greenhouse', 'Aksi'],
          rows: perangkatModel.map((perangkat) {
            return _buildPerangkatRow(perangkat, context);
          }).toList(),
        ));
  }

  DataRow _buildPerangkatRow(Perangkat perangkat, BuildContext context) {
    return DataRow(
      color: MaterialStateProperty.all(Colors.white),
      cells: [
        DataCell(Text(perangkat.nama ?? '')),
        DataCell(Text(perangkat.keterangan ?? '')),
        DataCell(Text(perangkat.greenhouseId ?? '')),
        DataCell(
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  final newDevice = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Tambah_perangkat(
                            greenhouses: greenhouses, perangkat: perangkat)),
                  );
                  if (newDevice != null) {
                    _editPerangkat(newDevice);
                  }
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () async {
                  bool? confirmDelete = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Anda Yakin?"),
                        content: const Text(
                            "Apakah Anda yakin ingin menghapus item ini?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(false); 
                            },
                            child: const Text("No"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(true); 
                            },
                            child: const Text("Yes"),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmDelete == true) {
                   
                    _deletePerangkat(perangkat.id);
                  }
                },
                icon: const Icon(Icons.delete),
                color: Colors.red,
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableContainer(Widget child) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFBAC6CB),
        borderRadius: BorderRadius.circular(5),
      ),
      child: child,
    );
  }

  Widget _buildDataTable(
      {required List<String> columns, required List<DataRow> rows}) {
    return DataTable(
      columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
      rows: rows,
    );
  }
}

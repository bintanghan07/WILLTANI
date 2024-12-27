import 'package:flutter/material.dart';
import 'package:webagro/chopper_api/api_client.dart';
import 'package:webagro/models/kontrol.dart';

class EditSettings extends StatefulWidget {
  final KontrolM kontrolM;
  final String token; 

  const EditSettings({
    super.key,
    required this.kontrolM,
    required this.token,
  });

  @override
  _EditSettingsState createState() => _EditSettingsState();
}

class _EditSettingsState extends State<EditSettings> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _suhuMinimalController;
  late TextEditingController _suhuMaximalController;
  late TextEditingController _tdsMinimalController;
  late TextEditingController _tdsMaximalController;
  late TextEditingController _kelembabanMinimalController;
  late TextEditingController _kelembabanMaximalController;
  late TextEditingController _volumeAirMinimalController;
  late TextEditingController _volumeAirMaximalController;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with values from KontrolM
    _suhuMinimalController =
        TextEditingController(text: widget.kontrolM.suhuMin.toString());
    _suhuMaximalController =
        TextEditingController(text: widget.kontrolM.suhuMax.toString());
    _tdsMinimalController =
        TextEditingController(text: widget.kontrolM.tdsMin.toString());
    _tdsMaximalController =
        TextEditingController(text: widget.kontrolM.tdsMax.toString());
    _kelembabanMinimalController =
        TextEditingController(text: widget.kontrolM.kelembabanMin.toString());
    _kelembabanMaximalController =
        TextEditingController(text: widget.kontrolM.kelembabanMax.toString());
    _volumeAirMinimalController =
        TextEditingController(text: widget.kontrolM.volumeMin.toString());
    _volumeAirMaximalController =
        TextEditingController(text: widget.kontrolM.volumeMax.toString());
  }

  @override
  void dispose() {
    _suhuMinimalController.dispose();
    _suhuMaximalController.dispose();
    _tdsMinimalController.dispose();
    _tdsMaximalController.dispose();
    _kelembabanMinimalController.dispose();
    _kelembabanMaximalController.dispose();
    _volumeAirMinimalController.dispose();
    _volumeAirMaximalController.dispose();
    super.dispose();
  }


  Future<void> _updateSettings() async {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'suhu_min': double.parse(_suhuMinimalController.text),
        'suhu_max': double.parse(_suhuMaximalController.text),
        'tds_min': int.parse(_tdsMinimalController.text),
        'tds_max': int.parse(_tdsMaximalController.text),
        'kelembaban_min': int.parse(_kelembabanMinimalController.text),
        'kelembaban_max': int.parse(_kelembabanMaximalController.text),
        'volume_min': int.parse(_volumeAirMinimalController.text),
        'volume_max': int.parse(_volumeAirMaximalController.text),
        'perangkat_id': widget.kontrolM.perangkatId,
      };

      try {
        final response = await ApiClient().apiService.updateKontrolData(
              'Bearer ${widget.token}', 
              widget.kontrolM.perangkatId, 
              updatedData, 
            );

        if (response.isSuccessful) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("sukses rubah setting!")));
          Navigator.pop(context, updatedData);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Update failed: ${response.error}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Edit Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF33697C),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabeledTextField('Suhu Minimal', _suhuMinimalController),
                const SizedBox(height: 10),
                _buildLabeledTextField('Suhu Maximal', _suhuMaximalController),
                const SizedBox(height: 10),
                _buildLabeledTextField('TDS Minimal', _tdsMinimalController),
                const SizedBox(height: 10),
                _buildLabeledTextField('TDS Maximal', _tdsMaximalController),
                const SizedBox(height: 10),
                _buildLabeledTextField(
                    'Kelembaban Minimal', _kelembabanMinimalController),
                const SizedBox(height: 10),
                _buildLabeledTextField(
                    'Kelembaban Maximal', _kelembabanMaximalController),
                const SizedBox(height: 10),
                _buildLabeledTextField(
                    'Volume Air Minimal', _volumeAirMinimalController),
                const SizedBox(height: 10),
                _buildLabeledTextField(
                    'Volume Air Maximal', _volumeAirMaximalController),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed:
                          _updateSettings, // Call the function to update settings
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF294A52),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Simpan'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledTextField(
      String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF33697C),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            fillColor: const Color(0xFFBAC6CB),
            filled: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50.0),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Field ini harus diisi';
            }
            return null;
          },
        ),
      ],
    );
  }
}

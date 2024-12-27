import 'package:flutter/material.dart';
import 'package:webagro/widgets/custom_appbar.dart';

class EditPerangkatPage extends StatefulWidget {
  final String name;
  final String id;
  final String description;
  final String greenhouse;

  const EditPerangkatPage({
    super.key,
    required this.name,
    required this.id,
    required this.description,
    required this.greenhouse,
  });

  @override
  _EditPerangkatPageState createState() => _EditPerangkatPageState();
}

class _EditPerangkatPageState extends State<EditPerangkatPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _idController;
  late TextEditingController _descriptionController;
  String? _selectedGreenhouse;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _idController = TextEditingController(text: widget.id);
    _descriptionController = TextEditingController(text: widget.description);
    _selectedGreenhouse = widget.greenhouse;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedDevice = {
      'name': _nameController.text,
      'id': _idController.text,
      'description': _descriptionController.text,
      'greenhouse': _selectedGreenhouse,
    };
    Navigator.pop(context, updatedDevice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        activityName: "Edit Perangkat",
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
                    'Edit Perangkat',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF33697C),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabeledTextField('Nama Perangkat', _nameController),
                const SizedBox(height: 10),
                _buildLabeledTextField('ID Perangkat', _idController),
                const SizedBox(height: 10),
                _buildLabeledTextField('Keterangan', _descriptionController),
                const SizedBox(height: 10),
                const Text(
                  'Greenhouse',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF33697C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBAC6CB),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50.0, 
                          decoration: BoxDecoration(
                            color: const Color(0xFFBAC6CB),
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        ),
                      ),
                      Container(
                        height: 50.0,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(50.0),
                            bottomRight: Radius.circular(50.0),
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () => _showGreenhouseDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF294A52),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0)),
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    20.0), 
                            elevation:
                                0, 
                          ),
                          child: Text(
                            _selectedGreenhouse ?? 'Pilih Greenhouse',
                            style: const TextStyle(
                              color:
                                  Colors.white, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _saveChanges,
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
                      child: const Text('Kembali'),
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

  void _showGreenhouseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Greenhouse'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  title: const Text('Greenhouse 1'),
                  onTap: () {
                    setState(() {
                      _selectedGreenhouse = 'Greenhouse 1';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Greenhouse 2'),
                  onTap: () {
                    setState(() {
                      _selectedGreenhouse = 'Greenhouse 2';
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Greenhouse 3'),
                  onTap: () {
                    setState(() {
                      _selectedGreenhouse = 'Greenhouse 3';
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
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

void main() {
  runApp(const MaterialApp(
    home: EditPerangkatPage(
      name: 'Perangkat 1',
      id: 'ID123',
      description: 'Deskripsi perangkat',
      greenhouse: 'Greenhouse 1',
    ),
  ));
}

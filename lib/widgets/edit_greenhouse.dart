import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webagro/widgets/custom_appbar.dart';
import 'dart:io';

class EditGreenhousePage extends StatefulWidget {
  final String name;
  final String owner;
  final String manager;
  final String address;
  final String size;
  final String plantType;
  final String telegramId;

  const EditGreenhousePage({
    super.key,
    required this.name,
    required this.owner,
    required this.manager,
    required this.address,
    required this.size,
    required this.plantType,
    required this.telegramId,
  });

  @override
  _EditGreenhousePageState createState() => _EditGreenhousePageState();
}

class _EditGreenhousePageState extends State<EditGreenhousePage> {
  final _formKey = GlobalKey<FormState>(); // Declare and initialize _formKey
  late TextEditingController _nameController;
  late TextEditingController _ownerController;
  late TextEditingController _managerController;
  late TextEditingController _addressController;
  late TextEditingController _sizeController;
  late TextEditingController _plantTypeController;
  late TextEditingController _telegramIdController;

  // File upload variable
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _ownerController = TextEditingController(text: widget.owner);
    _managerController = TextEditingController(text: widget.manager);
    _addressController = TextEditingController(text: widget.address);
    _sizeController = TextEditingController(text: widget.size);
    _plantTypeController = TextEditingController(text: widget.plantType);
    _telegramIdController = TextEditingController(text: widget.telegramId);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = pickedFile;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _managerController.dispose();
    _addressController.dispose();
    _sizeController.dispose();
    _plantTypeController.dispose();
    _telegramIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        activityName: "Edit Greenhouse",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign _formKey to the Form widget
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Edit Greenhouse',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF33697C),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabeledTextField('Nama Greenhouse', _nameController),
                const SizedBox(height: 10),
                _buildLabeledTextField('Pemilik', _ownerController),
                const SizedBox(height: 10),
                _buildLabeledTextField('Pengelola', _managerController),
                const SizedBox(height: 10),
                _buildLabeledTextField('Alamat', _addressController),
                const SizedBox(height: 10),
                _buildLabeledTextField('Ukuran', _sizeController),
                const SizedBox(height: 10),
                _buildLabeledTextField('Jenis Tanaman', _plantTypeController),
                const SizedBox(height: 10),
                _buildLabeledTextField('Telegram ID', _telegramIdController),
                const SizedBox(height: 10),
                const Text(
                  'Kondisi (Upload Gambar Ukuran Max 1 MB)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF33697C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  height: 50.0, // Set the height of the container
                  decoration: BoxDecoration(
                    color: const Color(0xFFBAC6CB),
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50.0, // Match the height of the button
                          decoration: BoxDecoration(
                            color: const Color(0xFFBAC6CB),
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _image == null
                                  ? const Text('No image selected.')
                                  : Image.file(
                                      File(_image!.path),
                                      fit: BoxFit.cover,
                                    ),
                            ),
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
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF294A52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    20.0), // Padding for the button text
                            elevation:
                                0, // Remove the button's shadow to match the container
                          ),
                          child: const Text(
                            'Choose File',
                            style: TextStyle(
                              color:
                                  Colors.white, // Set the text color to white
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final updatedGreenhouse = {
                            'name': _nameController.text,
                            'owner': _ownerController.text,
                            'manager': _managerController.text,
                            'address': _addressController.text,
                            'size': _sizeController.text,
                            'plantType': _plantTypeController.text,
                            'telegramId': _telegramIdController.text,
                          };

                          Navigator.pop(context, updatedGreenhouse);
                        }
                      },
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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webagro/chopper_api/api_client.dart';
import 'package:webagro/models/greenhouse.dart';
import 'package:webagro/widgets/custom_appbar.dart';
import 'package:webagro/widgets/greenhouse.dart';

class TambahGreenhouse extends StatefulWidget {
  TambahGreenhouse({super.key, this.greenhouse});
  GreenhouseM? greenhouse;
  @override
  _TambahGreenhouseState createState() => _TambahGreenhouseState();
}

class _TambahGreenhouseState extends State<TambahGreenhouse> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the text fields
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _addressController = TextEditingController();
  final _sizeController = TextEditingController();
  final _managerController = TextEditingController();
  final _plantTypeController = TextEditingController();
  final _telegramIdController = TextEditingController();

  // File upload variable
  XFile? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = pickedFile;
    });
  }

  String? token;

  final apiService = ApiClient().apiService;

  @override
  void initState() {
    super.initState();
    _initialize();
    if (widget.greenhouse != null) {
      _nameController.text = widget.greenhouse!.nama;
      _addressController.text = widget.greenhouse!.alamat;
      _sizeController.text = widget.greenhouse!.ukuran;
      _ownerController.text = widget.greenhouse!.pemilik;
      _managerController.text = widget.greenhouse!.pengelola;
    }
  }

  Future<void> _initialize() async {
    await _getToken();
  }

  Future<void> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('bearer_token');
    });
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _nameController.dispose();
    _ownerController.dispose();
    _addressController.dispose();
    _sizeController.dispose();
    _managerController.dispose();
    _plantTypeController.dispose();
    _telegramIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          activityName: widget.greenhouse == null
              ? 'Tambah Greenhouse'
              : 'Edit Greenhouse'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.greenhouse == null
                        ? 'Tambah Greenhouse'
                        : 'Edit Greenhouse',
                    style: const TextStyle(
                      fontSize: 24, // Larger font size
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF33697C),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabeledTextField('Nama', _nameController),
                const SizedBox(height: 10),
                _buildLabeledTextField('Pemilik', _ownerController),
                const SizedBox(height: 10),
                _buildLabeledTextField('Alamat', _addressController),
                const SizedBox(height: 10),
                _buildLabeledTextField('Luas', _sizeController),
                const SizedBox(height: 10),
                _buildLabeledTextField('Pengelola', _managerController),
                const SizedBox(height: 10),
                _buildLabeledTextField('Jenis Tanaman', _plantTypeController),
                const SizedBox(height: 10),
                _buildLabeledTextField('Telegram ID', _telegramIdController),
                const SizedBox(height: 10),
                const Text(
                  'Foto (Upload Gambar Ukuran Max 1 MB)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF33697C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50.0, // Match the height of the button
                        decoration: BoxDecoration(
                          color: const Color(0xFFBAC6CB),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _image == null
                                ? const Text('No image selected')
                                : const Text('Image Selected'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
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
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          elevation:
                              0, // Remove the button's shadow to match the container
                        ),
                        child: const Text(
                          'Choose File',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _submit();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF294A52),
                        foregroundColor: Colors.white,
                      ),
                      child: widget.greenhouse == null
                          ? const Text('Tambah')
                          : const Text('Edit'),
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

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      // Prepare form data
      final newGreenhouse = {
        'nama': _nameController.text,
        'pemilik': _ownerController.text,
        'alamat': _addressController.text,
        'ukuran': _sizeController.text,
        'pengelola': _managerController.text,
        'jenis_tanaman_id': _plantTypeController.text,
        'telegramId': _telegramIdController.text,
        'image': _image,
      };

      if (widget.greenhouse == null) {
        // Add greenhouse logic
        _addGreenhouse(newGreenhouse);
      } else {
        // Edit greenhouse logic
        _editGreenhouse(widget.greenhouse!.id, newGreenhouse);
      }
    }
  }

  Future<void> _editGreenhouse(
      int id, Map<String, dynamic> updatedGreenhouse) async {
    try {
      // Prepare image file as MultipartFile
      final imageFile = updatedGreenhouse['image'] as XFile?;
      http.MultipartFile? multipartImage;

      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        multipartImage = http.MultipartFile(
          'image',
          Stream.value(bytes),
          bytes.length,
          filename: imageFile.name,
          contentType: MediaType('image', imageFile.name.split('.').last),
        );
      }

      final response = await apiService.updateGreenhouse(
        'Bearer $token',
        updatedGreenhouse['nama'],
        updatedGreenhouse['alamat'],
        updatedGreenhouse['ukuran'],
        updatedGreenhouse['pemilik'],
        updatedGreenhouse['pengelola'],
        updatedGreenhouse['jenis_tanaman_id'],
        multipartImage?.filename ?? "",
        multipartImage!,
        id,
        // Ensure the image is sent
      );

      if (response.isSuccessful) {
        Navigator.pop(context, updatedGreenhouse);
      } else {
        print('Failed to add greenhouse: ${response.error}');
      }
    } catch (e) {
      print('Error adding greenhouse: $e');
    }
  }

  Future<void> _addGreenhouse(Map<String, dynamic> newGreenhouse) async {
    try {
      // Prepare image file as MultipartFile
      final imageFile = newGreenhouse['image'] as XFile?;
      http.MultipartFile? multipartImage;
      if (imageFile != null) {
        final bytes = await imageFile.readAsBytes();
        multipartImage = http.MultipartFile(
          'image',
          Stream.value(bytes),
          bytes.length,
          filename: imageFile.name,
          contentType: MediaType('image', imageFile.name.split('.').last),
        );
      }

      final response = await apiService.createGreenhouse(
        'Bearer $token',
        newGreenhouse['nama'],
        newGreenhouse['alamat'],
        newGreenhouse['ukuran'],
        newGreenhouse['pemilik'],
        newGreenhouse['pengelola'],
        newGreenhouse['jenis_tanaman_id'],
        multipartImage!.filename ?? "",
        multipartImage, // Ensure the image is sent
      );

      if (response.isSuccessful) {
        Navigator.pop(context, newGreenhouse);
      } else {
        print('Failed to add greenhouse: ${response.error}');
      }
    } catch (e) {
      print('Error adding greenhouse: $e');
    }
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

import 'package:flutter/material.dart';
import 'package:webagro/models/greenhouse.dart';
import 'package:webagro/models/perangkat.dart';
import 'package:webagro/widgets/custom_appbar.dart';

class Tambah_perangkat extends StatefulWidget {
  final List<GreenhouseM> greenhouses;
  Tambah_perangkat({super.key, required this.greenhouses, this.perangkat});

  Perangkat? perangkat;

  @override
  _TambahPerangkatState createState() => _TambahPerangkatState();
}

class _TambahPerangkatState extends State<Tambah_perangkat> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _perangkatid = TextEditingController();
  final _keterangan = TextEditingController();

  GreenhouseM? _selectedGreenhouse;

  @override
  void initState() {
    super.initState();
    if (widget.perangkat != null) {
      _nameController.text = widget.perangkat!.nama ?? '';
      _perangkatid.text = widget.perangkat!.id.toString() ?? '';
      _keterangan.text = widget.perangkat!.keterangan ?? '';
      _selectedGreenhouse = widget.greenhouses.firstWhere(
        (greenhouse) =>
            greenhouse.id.toString() == widget.perangkat!.greenhouseId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        activityName:
            widget.perangkat == null ? 'Tambah Perangkat' : 'Edit Perangkat',
      ),
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
                    widget.perangkat == null
                        ? 'Tambah Perangkat'
                        : 'Edit Perangkat',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF33697C),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabeledTextField('Nama', _nameController),
                const SizedBox(height: 10),
                _buildLabeledTextField('Perangkat ID', _perangkatid),
                const SizedBox(height: 10),
                _buildLabeledTextField('Keterangan', _keterangan),
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
                            _selectedGreenhouse?.nama ?? 'Pilih Greenhouse',
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final newDevice = {
                            'name': _nameController.text,
                            'id': _perangkatid.text,
                            'description': _keterangan.text,
                            'greenhouse_id':
                                _selectedGreenhouse?.id.toString() ?? "",
                          };

                          Navigator.pop(
                              context, newDevice); 
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF294A52),
                        foregroundColor: Colors.white,
                      ),
                      child: widget.perangkat == null
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

  void _showGreenhouseDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Greenhouse'),
          content: SingleChildScrollView(
            child: ListBody(
              children: widget.greenhouses.map((greenhouse) {
                return ListTile(
                  title: Text(greenhouse.nama),
                  onTap: () {
                    setState(() {
                      _selectedGreenhouse = greenhouse;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
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

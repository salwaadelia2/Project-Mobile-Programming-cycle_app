import 'package:flutter/material.dart';

class PrediksiPage extends StatefulWidget {
  final int userId;
  final String username;

  const PrediksiPage({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<PrediksiPage> createState() => _PrediksiPageState();
}

class _PrediksiPageState extends State<PrediksiPage> {
  final TextEditingController _tglHaidController = TextEditingController();
  final TextEditingController _siklusController = TextEditingController(text: '28');
  final TextEditingController _durasiController = TextEditingController(text: '7');

  String _hasilPrediksi = '';
  String _prediksiHaid = '';
  String _prediksiOvulasi = '';
  String _masaSubur = '';
  String _durasiHaid = '';

  String _formatTanggal(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  DateTime _parseTanggal(String tanggal) {
    List<String> parts = tanggal.split('/');
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  void _hitungPrediksi() {
    if (_tglHaidController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal haid terakhir wajib diisi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      DateTime tglHaid = _parseTanggal(_tglHaidController.text);
      int siklus = int.tryParse(_siklusController.text) ?? 28;
      int durasi = int.tryParse(_durasiController.text) ?? 7;

      DateTime tanggalSelesaiHaid = tglHaid.add(Duration(days: durasi - 1));
      DateTime prediksiHaid = tglHaid.add(Duration(days: siklus));
      DateTime prediksiOvulasi = prediksiHaid.subtract(Duration(days: 14));
      DateTime masaSuburMulai = prediksiOvulasi.subtract(Duration(days: 5));
      DateTime masaSuburSelesai = prediksiOvulasi.add(Duration(days: 1));

      setState(() {
        _durasiHaid = '${_formatTanggal(tglHaid)} - ${_formatTanggal(tanggalSelesaiHaid)}';
        _prediksiHaid = _formatTanggal(prediksiHaid);
        _prediksiOvulasi = _formatTanggal(prediksiOvulasi);
        _masaSubur = '${_formatTanggal(masaSuburMulai)} - ${_formatTanggal(masaSuburSelesai)}';
        _hasilPrediksi = '✅ Siklus Normal (Durasi: $durasi hari)';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format tanggal salah! Gunakan format: 22/5/2026'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetForm() {
    setState(() {
      _tglHaidController.clear();
      _siklusController.text = '28';
      _durasiController.text = '7';
      _hasilPrediksi = '';
      _prediksiHaid = '';
      _prediksiOvulasi = '';
      _masaSubur = '';
      _durasiHaid = '';
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF48FB1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = _formatTanggal(picked);
    }
  }

  Widget _buildResultItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.pink,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Prediksi Siklus'),
        backgroundColor: Colors.pink.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📝 Input Data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _selectDate(context, _tglHaidController),
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _tglHaidController,
                          decoration: InputDecoration(
                            labelText: 'Tanggal Pertama Haid Terakhir',
                            hintText: 'Contoh: 22/5/2026',
                            suffixIcon: const Icon(Icons.calendar_today, color: Colors.pink),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _siklusController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Rata-rata Siklus (hari)',
                        hintText: 'Contoh: 28',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _durasiController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Durasi Haid (hari)',
                        hintText: 'Contoh: 7',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _hitungPrediksi,
                            child: const Text('Hitung', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.pink,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.pink.shade400),
                            ),
                            onPressed: _resetForm,
                            child: const Text('Reset', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_hasilPrediksi.isNotEmpty) ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                color: Colors.pink.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.analytics, color: Colors.pink),
                          const SizedBox(width: 10),
                          Text(
                            _hasilPrediksi,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.pink),
                      const SizedBox(height: 10),
                      _buildResultItem('📅 Durasi Haid', _durasiHaid),
                      const SizedBox(height: 10),
                      _buildResultItem('📅 Haid Berikutnya', _prediksiHaid),
                      const SizedBox(height: 10),
                      _buildResultItem('🥚 Perkiraan Ovulasi', _prediksiOvulasi),
                      const SizedBox(height: 10),
                      _buildResultItem('❤️ Masa Subur', _masaSubur),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Catatan: Hasil ini hanya perkiraan berdasarkan data yang Anda masukkan.',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
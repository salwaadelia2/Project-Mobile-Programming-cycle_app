import 'package:flutter/material.dart';
import 'package:project_uts/services/menstruasi_service.dart';
import 'package:project_uts/services/mood_service.dart';
import 'package:project_uts/pages/prediksi_page.dart';
import 'package:project_uts/login.dart';

class MainPage extends StatefulWidget {
  final int userId;
  final String username;

  const MainPage({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final MenstruasiService _menstruasiService = MenstruasiService();
  final MoodService _moodService = MoodService();

  List<Map<String, dynamic>> _menstruasiList = [];
  bool _isLoading = true;

  int _defaultSiklus = 28;
  int _defaultDurasi = 7;

  final List<String> _moodOptions = [
    '😊 Senang',
    '😢 Sedih',
    '😠 Marah',
    '😰 Cemas',
    '😌 Tenang',
    '😩 Lelah',
    '🤩 Semangat',
    '😤 Kesal',
  ];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // ========== LOAD DATA ==========
  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await _loadMenstruasi();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _loadMenstruasi() async {
    _menstruasiList = await _menstruasiService.getAllMenstruasi(widget.userId);
    if (_menstruasiList.isNotEmpty) {
      var lastData = _menstruasiList[0];
      if (lastData['catatan'] != null && lastData['catatan'].contains('Siklus:')) {
        try {
          String catatan = lastData['catatan'];
          int start = catatan.indexOf('Siklus:') + 7;
          int end = catatan.indexOf('hari', start);
          if (end > start) {
            _defaultSiklus = int.parse(catatan.substring(start, end).trim());
          }
        } catch (_) {}
      }
    }
  }

  // ========== HITUNG SIKLUS KE OTOMATIS ==========
  int _getNextSiklusKe() {
    if (_menstruasiList.isEmpty) return 1;
    int maxSiklus = 0;
    for (var item in _menstruasiList) {
      int siklus = item['siklus_ke'] ?? 0;
      if (siklus > maxSiklus) {
        maxSiklus = siklus;
      }
    }
    return maxSiklus + 1;
  }

  // ========== EKSTRAK PREDIKSI DARI CATATAN ==========
  Map<String, String> _ekstrakPrediksi(String catatan) {
    String prediksiHaid = '';
    String masaSubur = '';
    String ovulasi = '';
    String selesai = '';
    String siklusInfo = '';
    String durasiInfo = '';
    String catatanUser = '';
    String mood = '';
    String tips = '';

    if (catatan.isNotEmpty) {
      int start = catatan.indexOf('Haid Berikutnya:');
      if (start != -1) {
        int end = catatan.indexOf('\n', start);
        prediksiHaid = catatan.substring(start + 17, end != -1 ? end : catatan.length).trim();
      }
      start = catatan.indexOf('Masa Subur:');
      if (start != -1) {
        int end = catatan.indexOf('\n', start);
        masaSubur = catatan.substring(start + 12, end != -1 ? end : catatan.length).trim();
      }
      start = catatan.indexOf('Ovulasi:');
      if (start != -1) {
        int end = catatan.indexOf('\n', start);
        ovulasi = catatan.substring(start + 9, end != -1 ? end : catatan.length).trim();
      }
      start = catatan.indexOf('Selesai:');
      if (start != -1) {
        int end = catatan.indexOf('\n', start);
        selesai = catatan.substring(start + 9, end != -1 ? end : catatan.length).trim();
      }
      start = catatan.indexOf('Siklus:');
      if (start != -1) {
        int end = catatan.indexOf('|', start);
        siklusInfo = catatan.substring(start, end != -1 ? end : catatan.length).trim();
      }
      start = catatan.indexOf('Durasi:');
      if (start != -1) {
        int end = catatan.indexOf('\n', start);
        durasiInfo = catatan.substring(start, end != -1 ? end : catatan.length).trim();
      }
      start = catatan.indexOf('😊');
      if (start != -1) {
        int end = catatan.indexOf('\n', start);
        mood = catatan.substring(start, end != -1 ? end : catatan.length).trim();
      }
      start = catatan.indexOf('💡 Tips:');
      if (start != -1) {
        int end = catatan.indexOf('\n', start + 7);
        tips = catatan.substring(start + 7, end != -1 ? end : catatan.length).trim();
      }
      start = catatan.indexOf('📝');
      if (start != -1) {
        int end = catatan.indexOf('\n', start);
        if (end == -1) end = catatan.length;
        String temp = catatan.substring(start + 2, end).trim();
        if (!temp.contains('😊') && !temp.contains('💡')) {
          catatanUser = temp;
        }
      }
    }

    return {
      'prediksi_haid': prediksiHaid,
      'masa_subur': masaSubur,
      'ovulasi': ovulasi,
      'selesai': selesai,
      'siklus_info': siklusInfo,
      'durasi_info': durasiInfo,
      'catatan_user': catatanUser,
      'mood': mood,
      'tips': tips,
    };
  }

  // ========== TAMBAH MENSTRUASI + MOOD ==========
  void _showTambahDialog() {
    final TextEditingController tglMulai = TextEditingController();
    final TextEditingController tglSelesai = TextEditingController();
    final TextEditingController catatan = TextEditingController();
    final TextEditingController siklusController = TextEditingController(text: _defaultSiklus.toString());
    final TextEditingController durasiController = TextEditingController(text: _defaultDurasi.toString());

    String selectedMood = _moodOptions[0];
    String tips = '';

    int siklusKeOtomatis = _getNextSiklusKe();
    final BuildContext mainContext = context;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          // Update tips saat mood berubah
          if (selectedMood.isNotEmpty) {
            tips = _moodService.getTipsByMood(selectedMood);
          }

          String prediksiText = '';
          if (tglMulai.text.isNotEmpty && siklusController.text.isNotEmpty) {
            try {
              int siklus = int.tryParse(siklusController.text) ?? _defaultSiklus;
              int durasi = int.tryParse(durasiController.text) ?? _defaultDurasi;
              var prediksi = _menstruasiService.hitungPrediksi(tglMulai.text, siklus, durasi);
              prediksiText = '''
📅 Selesai: ${prediksi['tanggal_selesai']}
📅 Haid Berikutnya: ${prediksi['prediksi_haid']}
🥚 Ovulasi: ${prediksi['prediksi_ovulasi']}
❤️ Masa Subur: ${prediksi['masa_subur']}
              ''';
            } catch (_) {
              prediksiText = '⚠️ Masukkan tanggal dengan benar';
            }
          } else {
            prediksiText = '📝 Isi tanggal mulai untuk melihat prediksi';
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.female, color: Colors.pink),
                const SizedBox(width: 10),
                const Text('Tambah Catatan', style: TextStyle(color: Colors.pink)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Siklus ke
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.pink.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🔄 Siklus ke-', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '$siklusKeOtomatis',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.pink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildDateField(context, 'Tanggal Mulai *', tglMulai, (_) => setStateDialog(() {})),
                  const SizedBox(height: 12),
                  _buildDateField(context, 'Tanggal Selesai', tglSelesai, (_) => setStateDialog(() {})),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: siklusController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Siklus (hari)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (_) => setStateDialog(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: durasiController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Durasi (hari)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (_) => setStateDialog(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 🔥 MOOD PICKER
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.pink.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '😊 Bagaimana perasaanmu?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _moodOptions.map((mood) {
                            bool isSelected = selectedMood == mood;
                            return FilterChip(
                              label: Text(mood, style: const TextStyle(fontSize: 12)),
                              selected: isSelected,
                              selectedColor: Colors.pink.shade100,
                              onSelected: (selected) {
                                setStateDialog(() {
                                  if (selected) selectedMood = mood;
                                  tips = _moodService.getTipsByMood(selectedMood);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        // 🔥 TIPS OTOMATIS
                        if (tips.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '💡 Tips untukmu:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(tips, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: catatan,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Catatan tambahan (opsional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink.shade50, Colors.pink.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.pink.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🔮 Prediksi Otomatis',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.pink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(prediksiText, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (tglMulai.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tanggal mulai wajib diisi!')),
                    );
                    return;
                  }

                  int siklus = int.tryParse(siklusController.text) ?? _defaultSiklus;
                  int durasi = int.tryParse(durasiController.text) ?? _defaultDurasi;
                  var prediksi = _menstruasiService.hitungPrediksi(tglMulai.text, siklus, durasi);

                  Navigator.pop(context);

                  String catatanLengkap = '''
📊 Siklus: $siklus hari | Durasi: $durasi hari
📅 Selesai: ${prediksi['tanggal_selesai']}
📅 Haid Berikutnya: ${prediksi['prediksi_haid']}
🥚 Ovulasi: ${prediksi['prediksi_ovulasi']}
❤️ Masa Subur: ${prediksi['masa_subur']}
$selectedMood
💡 Tips: $tips
📝 ${catatan.text}
                  ''';

                  bool success = await _menstruasiService.tambahMenstruasi(
                    userId: widget.userId,
                    tanggalMulai: tglMulai.text,
                    tanggalSelesai: tglSelesai.text.isEmpty ? prediksi['tanggal_selesai'] : tglSelesai.text,
                    siklusKe: siklusKeOtomatis,
                    catatan: catatanLengkap,
                  );

                  if (success) {
                    ScaffoldMessenger.of(mainContext).showSnackBar(
                      SnackBar(
                        content: Text('✅ Siklus ke-$siklusKeOtomatis berhasil ditambahkan!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    await _loadMenstruasi();
                    if (mounted) {
                      setState(() {});
                    }
                  } else {
                    ScaffoldMessenger.of(mainContext).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Gagal menambahkan data'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ========== EDIT MENSTRUASI ==========
  void _showEditDialog(Map<String, dynamic> data) {
    final TextEditingController tglMulai = TextEditingController(text: data['tanggal_mulai']);
    final TextEditingController tglSelesai = TextEditingController(text: data['tanggal_selesai'] ?? '');
    final TextEditingController catatan = TextEditingController();

    String catatanAsli = '';
    String moodSaatIni = '';
    if (data['catatan'] != null) {
      String fullCatatan = data['catatan'];
      int start = fullCatatan.indexOf('📝');
      if (start != -1) {
        int end = fullCatatan.indexOf('\n', start);
        if (end == -1) end = fullCatatan.length;
        catatanAsli = fullCatatan.substring(start + 2, end).trim();
      }
      // Cari mood
      for (var mood in _moodOptions) {
        if (fullCatatan.contains(mood)) {
          moodSaatIni = mood;
          break;
        }
      }
    }
    catatan.text = catatanAsli;

    String selectedMood = moodSaatIni.isNotEmpty ? moodSaatIni : _moodOptions[0];
    String tips = _moodService.getTipsByMood(selectedMood);

    int siklusLama = _defaultSiklus;
    int durasiLama = _defaultDurasi;
    if (data['catatan'] != null) {
      String catatanFull = data['catatan'];
      int start = catatanFull.indexOf('Siklus:');
      if (start != -1) {
        int end = catatanFull.indexOf('hari', start);
        if (end > start) {
          try {
            siklusLama = int.parse(catatanFull.substring(start + 7, end).trim());
          } catch (_) {}
        }
      }
      start = catatanFull.indexOf('Durasi:');
      if (start != -1) {
        int end = catatanFull.indexOf('hari', start);
        if (end > start) {
          try {
            durasiLama = int.parse(catatanFull.substring(start + 8, end).trim());
          } catch (_) {}
        }
      }
    }

    final TextEditingController siklusController = TextEditingController(text: siklusLama.toString());
    final TextEditingController durasiController = TextEditingController(text: durasiLama.toString());
    final BuildContext mainContext = context;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          // Update tips saat mood berubah
          if (selectedMood.isNotEmpty) {
            tips = _moodService.getTipsByMood(selectedMood);
          }

          String prediksiText = '';
          if (tglMulai.text.isNotEmpty && siklusController.text.isNotEmpty) {
            try {
              int siklus = int.tryParse(siklusController.text) ?? _defaultSiklus;
              int durasi = int.tryParse(durasiController.text) ?? _defaultDurasi;
              var prediksi = _menstruasiService.hitungPrediksi(tglMulai.text, siklus, durasi);
              prediksiText = '''
📅 Selesai: ${prediksi['tanggal_selesai']}
📅 Haid Berikutnya: ${prediksi['prediksi_haid']}
🥚 Ovulasi: ${prediksi['prediksi_ovulasi']}
❤️ Masa Subur: ${prediksi['masa_subur']}
              ''';
            } catch (_) {
              prediksiText = '⚠️ Masukkan tanggal dengan benar';
            }
          } else {
            prediksiText = '📝 Isi tanggal mulai untuk melihat prediksi';
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.edit, color: Colors.blue),
                const SizedBox(width: 10),
                const Text('Edit Catatan', style: TextStyle(color: Colors.blue)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🔄 Siklus ke-', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '${data['siklus_ke'] ?? 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildDateField(context, 'Tanggal Mulai *', tglMulai, (_) => setStateDialog(() {})),
                  const SizedBox(height: 12),
                  _buildDateField(context, 'Tanggal Selesai', tglSelesai, (_) => setStateDialog(() {})),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: siklusController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Siklus (hari)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (_) => setStateDialog(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: durasiController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Durasi (hari)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (_) => setStateDialog(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // MOOD PICKER
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '😊 Bagaimana perasaanmu?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _moodOptions.map((mood) {
                            bool isSelected = selectedMood == mood;
                            return FilterChip(
                              label: Text(mood, style: const TextStyle(fontSize: 12)),
                              selected: isSelected,
                              selectedColor: Colors.blue.shade100,
                              onSelected: (selected) {
                                setStateDialog(() {
                                  if (selected) selectedMood = mood;
                                  tips = _moodService.getTipsByMood(selectedMood);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        if (tips.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '💡 Tips untukmu:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(tips, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: catatan,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Catatan tambahan (opsional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.blue.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🔮 Prediksi Otomatis',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(prediksiText, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (tglMulai.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tanggal mulai wajib diisi!')),
                    );
                    return;
                  }

                  int siklus = int.tryParse(siklusController.text) ?? _defaultSiklus;
                  int durasi = int.tryParse(durasiController.text) ?? _defaultDurasi;
                  var prediksi = _menstruasiService.hitungPrediksi(tglMulai.text, siklus, durasi);

                  Navigator.pop(context);

                  String catatanLengkap = '''
📊 Siklus: $siklus hari | Durasi: $durasi hari
📅 Selesai: ${prediksi['tanggal_selesai']}
📅 Haid Berikutnya: ${prediksi['prediksi_haid']}
🥚 Ovulasi: ${prediksi['prediksi_ovulasi']}
❤️ Masa Subur: ${prediksi['masa_subur']}
$selectedMood
💡 Tips: $tips
📝 ${catatan.text}
                  ''';

                  bool success = await _menstruasiService.updateMenstruasi(
                    id: data['id'],
                    userId: widget.userId,
                    tanggalMulai: tglMulai.text,
                    tanggalSelesai: tglSelesai.text.isEmpty ? prediksi['tanggal_selesai'] : tglSelesai.text,
                    siklusKe: data['siklus_ke'] ?? 1,
                    catatan: catatanLengkap,
                  );

                  if (success) {
                    ScaffoldMessenger.of(mainContext).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Data berhasil diupdate!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    await _loadMenstruasi();
                    if (mounted) {
                      setState(() {});
                    }
                  } else {
                    ScaffoldMessenger.of(mainContext).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Gagal mengupdate data'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ========== HAPUS MENSTRUASI ==========
  Future<void> _hapusMenstruasi(Map<String, dynamic> data) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🗑️ Hapus Data?'),
        content: Text('Yakin ingin menghapus siklus ke-${data['siklus_ke'] ?? '?'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await _menstruasiService.hapusMenstruasi(widget.userId, data['id']);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Data berhasil dihapus'),
            backgroundColor: Colors.red,
          ),
        );
        await _loadMenstruasi();
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  // ========== DATE FIELD ==========
  Widget _buildDateField(
    BuildContext context,
    String label,
    TextEditingController controller,
    Function(String) onChanged,
  ) {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
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
          controller.text = picked.toIso8601String().split('T')[0];
          onChanged(controller.text);
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.pink),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }

  // ========== SUMMARY ITEM ==========
  Widget _buildSummaryItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // ========== TAB MENSTRUASI ==========
  Widget _buildMenstruasiTab() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade100, Colors.pink.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryItem('🩸', _menstruasiList.length.toString(), 'Total Siklus'),
              _buildSummaryItem(
                '📅',
                _menstruasiList.isNotEmpty ? _menstruasiList[0]['tanggal_mulai'] ?? '-' : '-',
                'Terakhir',
              ),
              _buildSummaryItem(
                '🔄',
                _menstruasiList.isNotEmpty ? '${_menstruasiList[0]['siklus_ke'] ?? 1}' : '0',
                'Siklus ke-',
              ),
            ],
          ),
        ),
        Expanded(
          child: _menstruasiList.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.female, size: 60, color: Colors.pink),
                      SizedBox(height: 16),
                      Text('Belum ada catatan menstruasi'),
                      Text('Tekan + untuk menambah'),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: _menstruasiList.length,
                  itemBuilder: (context, index) {
                    var data = _menstruasiList[index];
                    var prediksi = _ekstrakPrediksi(data['catatan'] ?? '');

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.pink.shade100,
                          child: Text(
                            '${data['siklus_ke'] ?? index + 1}',
                            style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          'Siklus ke-${data['siklus_ke'] ?? index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📅 ${data['tanggal_mulai'] ?? '-'} → ${data['tanggal_selesai'] ?? '-'}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            // Tampilkan mood di subtitle jika ada
                            if ((prediksi['mood'] ?? '').isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  prediksi['mood']!,
                                  style: const TextStyle(fontSize: 12, color: Colors.pink),
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditDialog(data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _hapusMenstruasi(data),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Siklus & Durasi
                                if ((prediksi['siklus_info'] ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.timeline, size: 18, color: Colors.pink),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            prediksi['siklus_info']!,
                                            style: const TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // Selesai
                                if ((prediksi['selesai'] ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle, size: 18, color: Colors.green),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Selesai: ${prediksi['selesai']}',
                                            style: const TextStyle(fontSize: 14, color: Colors.green),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // Haid Berikutnya
                                if ((prediksi['prediksi_haid'] ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_month, size: 18, color: Colors.pink),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Haid Berikutnya: ${prediksi['prediksi_haid']}',
                                            style: const TextStyle(fontSize: 14, color: Colors.pink),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // Ovulasi
                                if ((prediksi['ovulasi'] ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.favorite, size: 18, color: Colors.red),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Ovulasi: ${prediksi['ovulasi']}',
                                            style: const TextStyle(fontSize: 14, color: Colors.red),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // Masa Subur
                                if ((prediksi['masa_subur'] ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.favorite_border, size: 18, color: Colors.pink),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Masa Subur: ${prediksi['masa_subur']}',
                                            style: const TextStyle(fontSize: 14, color: Colors.pink),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // Tips
                                if ((prediksi['tips'] ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6, bottom: 6),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.blue.shade200),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '💡 Tips:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            prediksi['tips']!,
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                // Catatan User
                                if ((prediksi['catatan_user'] ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '📝 ${prediksi['catatan_user']}',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ========== BUILD ==========
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🌸 ${widget.username}'),
        backgroundColor: Colors.pink.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Prediksi Siklus',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PrediksiPage(
                    userId: widget.userId,
                    username: widget.username,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : _buildMenstruasiTab(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTambahDialog,
        backgroundColor: Colors.pink.shade400,
        tooltip: 'Tambah Catatan',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_uts/db_helper.dart';

class MoodService {
  static const String baseUrl = 'http://10.30.181.153/cycle_api/db.php';
  final DbHelper _db = DbHelper();

  // ========== AMBIL SEMUA MOOD ==========
  Future<List<Map<String, dynamic>>> getAllMood(int userId) async {
    List<Map<String, dynamic>> result = [];

    try {
      List<Map<String, dynamic>> lokalData = await _db.getMood(userId);
      result = lokalData;

      try {
        final response = await http
            .get(
              Uri.parse('$baseUrl?endpoint=mood&user_id=$userId'),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          List serverData = jsonDecode(response.body);
          if (serverData.isNotEmpty) {
            result = serverData.cast<Map<String, dynamic>>();

            var dbClient = await _db.db;
            await dbClient.delete(
              'mood',
              where: 'user_id = ?',
              whereArgs: [userId],
            );

            for (var data in serverData) {
              await _db.insertMood({
                'user_id': userId,
                'tanggal': data['tanggal'],
                'mood': data['mood'],
                'catatan': data['catatan'] ?? '',
              });
            }
          }
        }
      } catch (e) {
        print('Server timeout mood, pakai data lokal: $e');
      }
    } catch (e) {
      print('Error get all mood: $e');
      result = await _db.getMood(userId);
    }

    return result;
  }

  // ========== TAMBAH MOOD ==========
  Future<bool> tambahMood({
    required int userId,
    required String tanggal,
    required String mood,
    String catatan = '',
  }) async {
    try {
      int lokalId = await _db.insertMood({
        'user_id': userId,
        'tanggal': tanggal,
        'mood': mood,
        'catatan': catatan,
      });

      if (lokalId <= 0) {
        return false;
      }

      try {
        final response = await http
            .post(
              Uri.parse(baseUrl),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                'endpoint': 'tambah_mood',
                'user_id': userId,
                'tanggal': tanggal,
                'mood': mood,
                'catatan': catatan,
              }),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          if (result['status'] == 'sukses') {
            return true;
          }
        }
      } catch (e) {
        print('Server timeout, tapi mood tersimpan di lokal');
      }

      return true;
    } catch (e) {
      print('Error tambah mood: $e');
      return false;
    }
  }

  // ========== HAPUS MOOD ==========
  Future<bool> hapusMood(int userId, int id) async {
    try {
      int deleted = await _db.deleteMood(id);
      if (deleted <= 0) {
        return false;
      }

      try {
        final response = await http
            .delete(
              Uri.parse(baseUrl),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({
                'endpoint': 'mood',
                'id': id,
              }),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);
          if (result['status'] == 'sukses') {
            return true;
          }
        }
      } catch (e) {
        print('Server timeout, tapi mood terhapus di lokal');
      }

      return true;
    } catch (e) {
      print('Error hapus mood: $e');
      return false;
    }
  }

  // ========== 🔥 FUNGSI TIPS BERDASARKAN MOOD ==========
  String getTipsByMood(String mood) {
    String moodClean = mood.replaceAll(RegExp(r'[^a-zA-Z]'), '').toLowerCase();
    
    Map<String, String> tipsMap = {
      'senang': '🌸 Pertahankan kebahagiaanmu! Lakukan hal-hal yang kamu sukai dan bagikan kebahagiaan dengan orang terdekat.',
      'sedih': '🌈 Tidak apa-apa untuk merasa sedih. Luangkan waktu untuk diri sendiri, coba menulis jurnal, atau bicara dengan teman terpercaya.',
      'marah': '🧘 Ambil napas dalam-dalam. Coba hitung sampai 10, jalan-jalan sebentar, atau lakukan aktivitas fisik untuk melepaskan emosi.',
      'cemas': '🌿 Coba teknik pernapasan 4-7-8 (tarik 4 detik, tahan 7 detik, hembus 8 detik). Fokus pada hal yang bisa kamu kendalikan.',
      'tenang': '☮️ Nikmati momen tenang ini. Meditasi atau mendengarkan musik bisa membantu mempertahankan ketenanganmu.',
      'lelah': '💤 Tubuhmu butuh istirahat. Pastikan tidur cukup, minum air putih, dan jangan paksakan diri terlalu keras.',
      'semangat': '🚀 Energi positifmu luar biasa! Gunakan semangat ini untuk menyelesaikan tugas-tugas penting atau mencoba hal baru.',
      'kesal': '😤 Coba alihkan perhatian dengan aktivitas yang menyenangkan. Jangan biarkan rasa kesal mengendalikan harimu.',
    };

    for (var key in tipsMap.keys) {
      if (moodClean.contains(key)) {
        return tipsMap[key]!;
      }
    }

    return '💡 Jaga kesehatan fisik dan mental. Lakukan hal-hal yang membuatmu bahagia dan jangan ragu untuk meminta bantuan jika diperlukan.';
  }

  // ==========  SARAN  ==========
  Map<String, dynamic> getSaranLengkap(String mood) {
    String tips = getTipsByMood(mood);
    
    Map<String, List<String>> aktivitasMap = {
      'senang': ['📸 Abadikan momen bahagia', '🎵 Putar lagu favorit', '☕ Ngobrol dengan teman'],
      'sedih': ['📝 Tulis perasaanmu', '🎬 Nonton film komedi', '🚶 Jalan-jalan santai'],
      'marah': ['💪 Olahraga ringan', '🧘 Meditasi', '🎨 Ekspresikan lewat seni'],
      'cemas': ['🌿 Teknik pernapasan', '📖 Baca buku', '🎧 Dengarkan musik tenang'],
      'tenang': ['🧘 Lanjutkan meditasi', '📖 Baca buku inspiratif', '☕ Nikmati teh hangat'],
      'lelah': ['😴 Tidur siang', '🚿 Mandi air hangat', '🥤 Minum air putih'],
      'semangat': ['🏃 Olahraga', '📝 Kerjakan target', '🎯 Coba hal baru'],
      'kesal': ['🎨 Alihkan perhatian', '🚶 Jalan-jalan', '🎵 Dengarkan musik'],
    };

    List<String> aktivitas = ['💡 Lakukan aktivitas yang menyenangkan'];
    for (var key in aktivitasMap.keys) {
      if (mood.toLowerCase().contains(key)) {
        aktivitas = aktivitasMap[key]!;
        break;
      }
    }

    return {
      'tips': tips,
      'aktivitas': aktivitas,
    };
  }
}
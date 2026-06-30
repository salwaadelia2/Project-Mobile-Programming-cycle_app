import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_uts/db_helper.dart';

class MenstruasiService {
  static const String baseUrl = 'http://10.30.181.153/cycle_api/db.php';

  final DbHelper _db = DbHelper();

  int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  String _twoDigit(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _formatMysqlDate(DateTime date) {
    return '${date.year}-${_twoDigit(date.month)}-${_twoDigit(date.day)}';
  }

  DateTime _parseFlexibleDate(String tanggal) {
    if (tanggal.contains('/')) {
      List<String> parts = tanggal.split('/');
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      return DateTime(year, month, day);
    }

    return DateTime.parse(tanggal);
  }

  String? _mysqlDateFromInput(String? tanggal) {
    if (tanggal == null || tanggal.trim().isEmpty) {
      return null;
    }

    try {
      DateTime date = _parseFlexibleDate(tanggal.trim());
      return _formatMysqlDate(date);
    } catch (_) {
      return tanggal;
    }
  }

  // ========== AMBIL SEMUA DATA ==========
  Future<List<Map<String, dynamic>>> getAllMenstruasi(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl?endpoint=menstruasi&user_id=$userId'),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          var dbClient = await _db.db;

          await dbClient.delete(
            'menstruasi',
            where: 'user_id = ?',
            whereArgs: [userId],
          );

          List<Map<String, dynamic>> serverData = [];

          for (var item in decoded) {
            final data = Map<String, dynamic>.from(item);

            final fixedData = {
              'id': _toInt(data['id']),
              'user_id': _toInt(data['user_id'], defaultValue: userId),
              'tanggal_mulai': data['tanggal_mulai'] ?? '',
              'tanggal_selesai': data['tanggal_selesai'],
              'siklus_ke': _toInt(data['siklus_ke'], defaultValue: 1),
              'catatan': data['catatan'] ?? '',
            };

            await _db.insertMenstruasi(fixedData);
            serverData.add(fixedData);
          }

          return serverData;
        }
      }

      return await _db.getMenstruasi(userId);
    } catch (e) {
      print('Server error, pakai data lokal: $e');
      return await _db.getMenstruasi(userId);
    }
  }

  // ========== TAMBAH DATA ==========
  Future<bool> tambahMenstruasi({
    required int userId,
    required String tanggalMulai,
    String? tanggalSelesai,
    int siklusKe = 1,
    String catatan = '',
  }) async {
    try {
      final tanggalMulaiMysql = _mysqlDateFromInput(tanggalMulai);
      final tanggalSelesaiMysql = _mysqlDateFromInput(tanggalSelesai);

      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              'endpoint': 'tambah_menstruasi',
              'user_id': userId,
              'tanggal_mulai': tanggalMulaiMysql,
              'tanggal_selesai': tanggalSelesaiMysql,
              'siklus_ke': siklusKe,
              'catatan': catatan,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Tambah menstruasi response: ${response.statusCode}');
      print('Tambah menstruasi body: ${response.body}');

      if (response.statusCode != 200) {
        return false;
      }

      final result = jsonDecode(response.body);

      if (result['status'] == 'sukses') {
        final serverId = _toInt(result['id']);

        await _db.insertMenstruasi({
          'id': serverId,
          'user_id': userId,
          'tanggal_mulai': tanggalMulaiMysql,
          'tanggal_selesai': tanggalSelesaiMysql,
          'siklus_ke': siklusKe,
          'catatan': catatan,
        });

        return true;
      }

      print('Gagal simpan MySQL: ${result['message']}');
      return false;
    } catch (e) {
      print('Error tambah menstruasi ke MySQL: $e');
      return false;
    }
  }

  // ========== HAPUS DATA ==========
  Future<bool> hapusMenstruasi(int userId, int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              'endpoint': 'menstruasi',
              'id': id,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Hapus menstruasi response: ${response.body}');

      if (response.statusCode != 200) {
        return false;
      }

      final result = jsonDecode(response.body);

      if (result['status'] == 'sukses') {
        await _db.deleteMenstruasi(id);
        return true;
      }

      print('Gagal hapus MySQL: ${result['message']}');
      return false;
    } catch (e) {
      print('Error hapus menstruasi: $e');
      return false;
    }
  }

  // ========== UPDATE DATA ==========
  Future<bool> updateMenstruasi({
    required int id,
    required int userId,
    required String tanggalMulai,
    String? tanggalSelesai,
    int siklusKe = 1,
    String catatan = '',
  }) async {
    try {
      final tanggalMulaiMysql = _mysqlDateFromInput(tanggalMulai);
      final tanggalSelesaiMysql = _mysqlDateFromInput(tanggalSelesai);

      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              'endpoint': 'update_menstruasi',
              'id': id,
              'user_id': userId,
              'tanggal_mulai': tanggalMulaiMysql,
              'tanggal_selesai': tanggalSelesaiMysql,
              'siklus_ke': siklusKe,
              'catatan': catatan,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Update menstruasi response: ${response.body}');

      if (response.statusCode != 200) {
        return false;
      }

      final result = jsonDecode(response.body);

      if (result['status'] == 'sukses') {
        await _db.updateMenstruasi({
          'id': id,
          'user_id': userId,
          'tanggal_mulai': tanggalMulaiMysql,
          'tanggal_selesai': tanggalSelesaiMysql,
          'siklus_ke': siklusKe,
          'catatan': catatan,
        });

        return true;
      }

      print('Gagal update MySQL: ${result['message']}');
      return false;
    } catch (e) {
      print('Error update menstruasi: $e');
      return false;
    }
  }

  // ========== FUNGSI PREDIKSI OTOMATIS ==========
  Map<String, String> hitungPrediksi(String tanggalMulai, int siklus, int durasi) {
    try {
      DateTime tglMulai = _parseFlexibleDate(tanggalMulai);

      DateTime tglSelesai = tglMulai.add(Duration(days: durasi - 1));
      DateTime prediksiHaid = tglMulai.add(Duration(days: siklus));
      DateTime prediksiOvulasi = prediksiHaid.subtract(const Duration(days: 14));
      DateTime masaSuburMulai = prediksiOvulasi.subtract(const Duration(days: 5));
      DateTime masaSuburSelesai = prediksiOvulasi.add(const Duration(days: 1));

      return {
        'tanggal_selesai': _formatMysqlDate(tglSelesai),
        'prediksi_haid': _formatMysqlDate(prediksiHaid),
        'prediksi_ovulasi': _formatMysqlDate(prediksiOvulasi),
        'masa_subur': '${_formatMysqlDate(masaSuburMulai)} - ${_formatMysqlDate(masaSuburSelesai)}',
        'durasi': '$durasi hari',
        'siklus': '$siklus hari',
      };
    } catch (e) {
      print('Error hitung prediksi: $e');

      return {
        'tanggal_selesai': '-',
        'prediksi_haid': '-',
        'prediksi_ovulasi': '-',
        'masa_subur': '-',
        'durasi': '-',
        'siklus': '-',
      };
    }
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_uts/db_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final DbHelper _db = DbHelper();

  // 🔥 IP SUDAH DIUPDATE
  final String baseUrl = 'http://10.30.181.153/cycle_api/db.php';

  Future<void> register() async {
    // Validasi input kosong
    if (username.text.isEmpty ||
        password.text.isEmpty ||
        confirmPassword.text.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Warning"),
          content: Text("Semua field wajib diisi"),
        ),
      );
      return;
    }

    // Validasi password match
    if (password.text != confirmPassword.text) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Error"),
          content: Text("Password dan konfirmasi tidak sama"),
        ),
      );
      return;
    }

    // Cek username di lokal
    bool taken = await _db.isUsernameTaken(username.text);
    if (taken) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Gagal"),
          content: Text("Username sudah digunakan!"),
        ),
      );
      return;
    }

    // 🔥 CEK KONEKSI INTERNET
    try {
      final testResponse = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 3));
      if (testResponse.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Tidak ada koneksi ke server! Periksa koneksi internet Anda.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Tidak ada koneksi ke server! Periksa koneksi internet Anda.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Simpan ke lokal
    int localId = await _db.register(username.text, password.text);

    if (localId > 0) {
      try {
        var url = Uri.parse(baseUrl);
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "endpoint": "register",
            "username": username.text,
            "password": password.text,
          }),
        );

        final data = jsonDecode(response.body);

        if (data['status'] == 'sukses') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Registrasi berhasil! Silakan login.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ Registrasi lokal berhasil, server: ${data['message']}'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Registrasi lokal berhasil, server error: $e'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Gagal"),
          content: Text("Gagal menyimpan data di lokal"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌸 Registrasi"),
        backgroundColor: Colors.pink.shade400,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Image.asset("images/banner.png", height: 150),
              const SizedBox(height: 20),
              TextField(
                controller: username,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              // 🔥 PASSWORD DENGAN TOMBOL LIHAT
              TextField(
                controller: password,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock, color: Colors.pink),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.pink,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              // 🔥 KONFIRMASI PASSWORD DENGAN TOMBOL LIHAT
              TextField(
                controller: confirmPassword,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.pink),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.pink,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: register,
                  child: const Text("Register", style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Sudah punya akun? Login", style: TextStyle(color: Colors.pink)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
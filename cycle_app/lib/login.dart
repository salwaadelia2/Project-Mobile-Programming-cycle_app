import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project_uts/db_helper.dart';
import 'package:project_uts/mainPage.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _konfirmasi = TextEditingController();

  final DbHelper _db = DbHelper();

  final String baseUrl = 'http://10.30.181.153/cycle_api/db.php';

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<bool> _cekServer() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Server tidak bisa diakses: $e');
      return false;
    }
  }

  Future<void> _login() async {
    if (_username.text.trim().isEmpty || _password.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username & password wajib diisi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final username = _username.text.trim();
    final password = _password.text.trim();

    final serverAktif = await _cekServer();

    if (!serverAktif) {
      final userLokal = await _db.login(username, password);

      if (!mounted) return;

      if (userLokal != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Login offline. Data hanya tersimpan lokal sampai server aktif.'),
            backgroundColor: Colors.orange,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainPage(
              userId: userLokal['id'] as int,
              username: userLokal['username'] as String,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server tidak aktif dan akun lokal tidak ditemukan.'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "endpoint": "login",
              "username": username,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Login response: ${response.body}');

      if (response.statusCode != 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server error saat login.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final data = jsonDecode(response.body);

      if (data['status'] == 'sukses') {
        final userData = data['data'];
        final int serverUserId = _toInt(userData['id']);

        if (serverUserId <= 0) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ID user dari server tidak valid.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await _db.saveUserFromServer(
          id: serverUserId,
          username: userData['username'],
          password: password,
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainPage(
              userId: serverUserId,
              username: userData['username'],
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Username atau password salah!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error koneksi server: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _register() async {
    if (_username.text.trim().isEmpty ||
        _password.text.trim().isEmpty ||
        _konfirmasi.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field wajib diisi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_password.text.trim() != _konfirmasi.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password dan konfirmasi tidak sama!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final serverAktif = await _cekServer();

    if (!serverAktif) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Server tidak aktif. Registrasi harus online agar masuk MySQL.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final username = _username.text.trim();
    final password = _password.text.trim();

    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "endpoint": "register",
              "username": username,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Register response: ${response.body}');

      if (response.statusCode != 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Server error saat registrasi.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final data = jsonDecode(response.body);

      if (data['status'] == 'sukses') {
        final int serverUserId = _toInt(data['id']);

        if (serverUserId <= 0) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrasi berhasil, tapi ID server tidak valid.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await _db.saveUserFromServer(
          id: serverUserId,
          username: username,
          password: password,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Registrasi berhasil! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          isLogin = true;
          _password.clear();
          _konfirmasi.clear();
        });
      } else {
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('❌ Registrasi Gagal'),
            content: Text(data['message'] ?? 'Terjadi kesalahan di server'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK', style: TextStyle(color: Colors.pink)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('⚠️ Koneksi Gagal'),
          content: Text('Tidak dapat terhubung ke server: $e'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.pink)),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _konfirmasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF0F5), Color(0xFFFCE4EC)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'images/banner.png',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.female,
                        size: 50,
                        color: Colors.pink,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      '🌸 Siklus Menstruasi 🌸',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                    const Text(
                      'Catat siklus & mood harianmu',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _username,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.person, color: Colors.pink),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock, color: Colors.pink),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.pink,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    if (!isLogin) ...[
                      const SizedBox(height: 15),
                      TextField(
                        controller: _konfirmasi,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Password',
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.pink,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.pink,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: isLogin ? _login : _register,
                        child: Text(
                          isLogin ? 'Login' : 'Registrasi',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                          _password.clear();
                          _konfirmasi.clear();
                          _obscurePassword = true;
                          _obscureConfirmPassword = true;
                        });
                      },
                      child: Text(
                        isLogin
                            ? 'Belum punya akun? Daftar'
                            : 'Sudah punya akun? Masuk',
                        style: const TextStyle(color: Colors.pink),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
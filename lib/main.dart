import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'alat.dart';
import 'kalender.dart';
import 'kas.dart';
import 'models.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Kas Kelas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// LOG IN
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  int _salahPercobaan = 0;
  bool _isLocked = false;
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _startLockTimer() {
    setState(() {
      _isLocked = true;
      _secondsRemaining = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isLocked = false;
          _salahPercobaan = 0;
        });
      }
    });
  }

  void _login() {
    if (_isLocked) return;

    if (akunBendahara.verifikasi(_userController.text, _passController.text)) {
      _salahPercobaan = 0;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } else {
      setState(() {
        _salahPercobaan++;
      });

      if (_salahPercobaan >= 3) {
        _startLockTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Gagal 3 kali! Akses dikunci sementara selama 30 detik.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        int sisa = 3 - _salahPercobaan;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Username atau Password salah! Sisa percobaan: $sisa kali.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 70,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'SISTEM KAS KELAS',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const Text(
                    '$namaKelas - $mataKuliah',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _userController,
                    enabled: !_isLocked,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passController,
                    enabled: !_isLocked,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isLocked) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_clock, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Terkunci! Coba lagi dalam $_secondsRemaining detik',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLocked ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _isLocked ? 'Akses Dikunci' : 'Login Bendahara',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// NAVIGASI UTAMA
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _bottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HalamanUtamaMenu(),
      const StopwatchWidget(),
      BantuanLogoutWidget(
        onLogout: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistem Kas Kelas'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: pages[_bottomIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: (index) => setState(() => _bottomIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Utama'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Stopwatch'),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Bantuan & Logout',
          ),
        ],
      ),
    );
  }
}

// MENU BERANDA
class HalamanUtamaMenu extends StatelessWidget {
  const HalamanUtamaMenu({super.key});

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: Icon(icon, color: Colors.teal),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apps, size: 60, color: Colors.teal),
            const SizedBox(height: 8),
            const Text(
              'MENU UTAMA APLIKASI',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const Text(
              'Pilih fitur di bawah ini',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _buildMenuButton(
              context,
              title: '1. Daftar Anggota Pengurus',
              icon: Icons.group,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Daftar Anggota Pengurus'),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                      body: DataPengurusWidget(onRefresh: () {}),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildMenuButton(
              context,
              title: '2. Perhitungan Kas Kelas',
              icon: Icons.account_balance_wallet,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MenuKasKomputasi(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildMenuButton(
              context,
              title: '3. Konversi Tanggal Hijriah',
              icon: Icons.calendar_month,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KonversiHijriah(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildMenuButton(
              context,
              title: '4. Konversi Tanggal Lahir Ke Umur',
              icon: Icons.cake,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KonversiUmurDetailPaging(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildMenuButton(
              context,
              title: '5. Kalender Weton & Saka Bali',
              icon: Icons.event_note,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KalenderWetonSaka(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
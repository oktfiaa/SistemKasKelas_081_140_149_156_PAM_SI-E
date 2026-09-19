import 'dart:async';
import 'package:flutter/material.dart';

// STOPWATCH
class StopwatchWidget extends StatefulWidget {
  const StopwatchWidget({super.key});

  @override
  State<StopwatchWidget> createState() => _StopwatchWidgetState();
}

class _StopwatchWidgetState extends State<StopwatchWidget> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<String> _laps = [];

  void _startStopwatch() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {});
    });
  }

  void _pauseStopwatch() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {});
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    _laps.clear();
    setState(() {});
  }

  void _addLap() {
    if (_stopwatch.isRunning) {
      setState(() {
        _laps.add(_formatTime(_stopwatch.elapsedMilliseconds));
      });
    }
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate() % 100;
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / (1000 * 60)).truncate() % 60;

    String minutesStr = (minutes < 10) ? '0$minutes' : '$minutes';
    String secondsStr = (seconds < 10) ? '0$seconds' : '$seconds';
    String hundredsStr = (hundreds < 10) ? '0$hundreds' : '$hundreds';

    return '$minutesStr:$secondsStr.$hundredsStr';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            _formatTime(_stopwatch.elapsedMilliseconds),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _stopwatch.isRunning
                    ? _pauseStopwatch
                    : _startStopwatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _stopwatch.isRunning
                      ? Colors.orange
                      : Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: Text(_stopwatch.isRunning ? 'Pause' : 'Start'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _stopwatch.isRunning ? _addLap : null,
                child: const Text('Lap'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _resetStopwatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _laps.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Text('Lap ${index + 1}'),
                  trailing: Text(
                    _laps[index],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// BANTUAN & LOGOUT
class BantuanLogoutWidget extends StatelessWidget {
  final VoidCallback onLogout;
  const BantuanLogoutWidget({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // <-- Bikin ikon sejajar di ATAS
              children: [
                Icon(Icons.menu_book, color: Colors.teal), // <-- Ganti jadi ikon buku/panduan
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Panduan Penggunaan Aplikasi',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. Daftar Anggota Pengurus: Lihat struktur dan informasi pengurus kelas.\n'
                        '2. Perhitungan Kas Kelas: Catat & hitung transaksi pemasukan serta pengeluaran kas.\n'
                        '3. Konversi Tanggal Hijriah: Ubah penanggalan Masehi ke kalender Hijriah.\n'
                        '4. Konversi Tanggal Lahir Ke Umur: Hitung rincian usia berdasarkan tanggal lahir.\n'
                        '5. Kalender Weton & Saka Bali: Cek hitungan Weton Jawa dan tanggal Saka Bali.\n'
                        '6. Fitur Stopwatch: Pengukur waktu akurat yang dapat diakses dari menu bawah.',
                        style: TextStyle(height: 1.5, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Logout Dari Akun'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}
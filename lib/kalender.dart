import 'package:flutter/material.dart';
import 'models.dart';

// KONVERSI HIJRIAH
class KonversiHijriah extends StatefulWidget {
  const KonversiHijriah({super.key});

  @override
  State<KonversiHijriah> createState() => _KonversiHijriahState();
}

class _KonversiHijriahState extends State<KonversiHijriah> {
  DateTime _selectedDate = DateTime.now();
  String _hasilHijriah = '';

  void _konversiToHijriah(DateTime date) {
    int day = date.day;
    int month = date.month;
    int year = date.year;

    int m = month;
    int y = year;
    if (m < 3) {
      y -= 1;
      m += 12;
    }

    int a = (y / 100).floor();
    int b = 2 - a + (a / 4).floor();
    int jd =
        (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524;

    int l = jd - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    int j =
        (((10985 - l) / 5316)).floor() * (((50 * l) / 17719)).floor() +
        (((l / 5670)).floor()) * (((43 * l) / 15238)).floor();
    l =
        l -
        (((30 - j) / 15)).floor() * (((17719 * j) / 50)).floor() -
        ((j / 16)).floor() * (((15238 * j) / 43)).floor() +
        29;
    int hMonth = ((24 * l) / 709).floor();
    int hDay = l - ((709 * hMonth) / 24).floor();
    int hYear = 30 * n + j - 30;

    List<String> namaBulanHijriah = [
      'Muharram','Safar','Rabiul Awal','Rabiul Akhir','Jumadil Awal','Jumadil Akhir',
      'Rajab','Sya\'ban','Ramadhan','Syawal','Zulqa\'dah','Zulhijjah',
    ];

    String namaBulan = (hMonth >= 1 && hMonth <= 12)
        ? namaBulanHijriah[hMonth - 1]
        : 'Muharram';

    setState(() {
      _hasilHijriah = '$hDay $namaBulan $hYear H';
    });
  }

  @override
  void initState() {
    super.initState();
    _konversiToHijriah(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    String tglMasehiFormatted =
        '${_selectedDate.day} ${bulanMasehiGlobal[_selectedDate.month]} ${_selectedDate.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Tanggal Hijriah'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Pilih Tanggal Masehi:'),
                subtitle: Text(
                  tglMasehiFormatted,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: const Icon(Icons.calendar_today, color: Colors.teal),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                    _konversiToHijriah(picked);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('Hasil Konversi Hijriah:'),
                    const SizedBox(height: 8),
                    Text(
                      _hasilHijriah,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// KONVERSI UMUR
class KonversiUmurDetailPaging extends StatefulWidget {
  const KonversiUmurDetailPaging({super.key});

  @override
  State<KonversiUmurDetailPaging> createState() =>
      _KonversiUmurDetailPagingState();
}

class _KonversiUmurDetailPagingState extends State<KonversiUmurDetailPaging> {
  DateTime? _tglLahir;
  String _detailUmur = '';

  void _hitungUmur() {
    if (_tglLahir == null) return;
    DateTime sekarang = DateTime.now();
    Duration beda = sekarang.difference(_tglLahir!);

    int tahun = sekarang.year - _tglLahir!.year;
    int bulan = sekarang.month - _tglLahir!.month;
    int hari = sekarang.day - _tglLahir!.day;

    if (hari < 0) {
      bulan -= 1;
      hari += 30;
    }
    if (bulan < 0) {
      tahun -= 1;
      bulan += 12;
    }

    int totalHari = beda.inDays;
    int totalJam = beda.inHours;
    int totalMenit = beda.inMinutes;
    int totalDetik = beda.inSeconds;

    setState(() {
      _detailUmur =
          'Umur Anda:\n• $tahun Tahun, $bulan Bulan, $hari Hari\n\nDetail Waktu Hidup:\n'
          '• Total Hari : $totalHari hari\n'
          '• Total Jam  : $totalJam jam\n'
          '• Total Menit: $totalMenit menit\n'
          '• Total Detik: $totalDetik detik';
    });
  }

  @override
  Widget build(BuildContext context) {
    String tglLahirFormatted = _tglLahir == null
        ? 'Pilih Tanggal Lahir'
        : 'Tgl Lahir: ${_tglLahir!.day} ${bulanMasehiGlobal[_tglLahir!.month]} ${_tglLahir!.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Umur & Detail Waktu'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text(tglLahirFormatted),
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2005, 8, 19),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _tglLahir = picked);
                  _hitungUmur();
                }
              },
            ),
            const SizedBox(height: 20),
            if (_detailUmur.isNotEmpty)
              Card(
                color: Colors.teal.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _detailUmur,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// KALENDER WETON & SAKA BALI
class KalenderWetonSaka extends StatefulWidget {
  const KalenderWetonSaka({super.key});

  @override
  State<KalenderWetonSaka> createState() => _KalenderWetonSakaState();
}

class _KalenderWetonSakaState extends State<KalenderWetonSaka> {
  DateTime _selectedDate = DateTime.now();

  Map<String, dynamic> _hitungWetonLengkap(DateTime date) {
    List<String> pasaranList = ['Legi', 'Pahing', 'Pon', 'Wage', 'Kliwon'];
    List<String> hariList = [
      'Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Minggu',
    ];

    DateTime baseDate = DateTime(1900, 1, 1);
    int diffDays = date.difference(baseDate).inDays;

    String namaHari = hariList[(date.weekday - 1) % 7];
    String namaPasaran = pasaranList[(diffDays + 1) % 5];

    Map<String, int> neptuSaptawara = {
      'Minggu': 5,'Senin': 4,'Selasa': 3,'Rabu': 7,
      'Kamis': 8,'Jumat': 6,'Sabtu': 9,
    };
    Map<String, int> neptuPancawara = {
      'Legi': 5,'Pahing': 9,'Pon': 7,'Wage': 4,'Kliwon': 8,
    };

    int nSaptawara = neptuSaptawara[namaHari] ?? 0;
    int nPancawara = neptuPancawara[namaPasaran] ?? 0;
    int totalSaptaPanca = nSaptawara + nPancawara;

    Map<String, int> neptuPancasudaHari = {
      'Minggu': 5,'Senin': 4,'Selasa': 3,'Rabu': 6,'Kamis': 8,'Jumat': 7,'Sabtu': 9,
    };
    int nPancasudaHari = neptuPancasudaHari[namaHari] ?? 0;
    int nPancasudaPasaran = neptuPancawara[namaPasaran] ?? 0;
    int totalPancasuda = nPancasudaHari + nPancasudaPasaran;

    Map<String, int> neptuKamarokamHari = {
      'Minggu': 3,'Senin': 4,'Selasa': 5,'Rabu': 6, 
      'Kamis': 7,'Jumat': 1, 'Sabtu': 2,
    };
    Map<String, int> neptuKamarokamPasaran = {
      'Kliwon': 1,'Legi': 2,'Pahing': 3,'Pon': 4,'Wage': 5,
    };
    int nKamarokamHari = neptuKamarokamHari[namaHari] ?? 0;
    int nKamarokamPasaran = neptuKamarokamPasaran[namaPasaran] ?? 0;
    int totalKamarokam = nKamarokamHari + nKamarokamPasaran;

    List<String> watakKamarokam = [
      'Kala Tinantang: Kurang beruntung, banyak tantangan.',
      'Demang Kadhuruwan: Sering mendapat perkara / masalah.',
      'Satriya Wibawa: Selalu mendapat kemudahan dan kebahagiaan.',
      'Sumur Sinaba: Menjadi tempat berguru dan dimintai nasehat.',
      'Macan Ketawan: SEDANG, Disegani, Dijauhi.',
      'Kala Basa: Sering mendapat ancaman atau bahaya.',
      'Satriya Lelaku: Suka mengembara, prihatin, banyak cobaan.',
    ];
    String watak = watakKamarokam[totalKamarokam % 7];

    return {
      'weton': '$namaHari $namaPasaran',
      'pancasudaText':
          'Pancasuda: $namaHari ($nPancasudaHari) + $namaPasaran ($nPancasudaPasaran) = $totalPancasuda',
      'saptaPancaText':
          'Saptawara & Pancawara: $namaHari ($nSaptawara) + $namaPasaran ($nPancawara) = $totalSaptaPanca',
      'kamarokamText':
          'Kamarokam: $namaHari ($nKamarokamHari) + $namaPasaran ($nKamarokamPasaran) = $totalKamarokam',
      'watakHari': watak,
    };
  }

  Map<String, String> _getSakaBaliLengkap(DateTime date) {
    int tahunMasehi = date.year;
    int tahunSaka = tahunMasehi - 78;

    bool sebelumNyepi = date.month < 3 || (date.month == 3 && date.day < 19);
    if (sebelumNyepi) {
      tahunSaka -= 1;
    }

    String rumustext = sebelumNyepi
        ? 'Perhitungan: $tahunMasehi - 78 - 1 = $tahunSaka Saka (Sebelum Nyepi)'
        : 'Perhitungan: $tahunMasehi - 78 = $tahunSaka Saka (Setelah Nyepi)';

    String sasih = '';
    String sebutanUrutan = '';

    switch (date.month) {
      case 1:
        sasih = 'Sasih Kapitu';
        sebutanUrutan = 'Bulan Ketujuh';
        break;
      case 2:
        sasih = 'Sasih Kawalu';
        sebutanUrutan = 'Bulan Kedelapan';
        break;
      case 3:
        if (date.day < 19) {
          sasih = 'Sasih Kasanga';
          sebutanUrutan = 'Bulan Kesembilan (Akhir Tahun)';
        } else {
          sasih = 'Sasih Kadasa';
          sebutanUrutan = 'Bulan Kesepuluh (Awal Tahun Baru)';
        }
        break;
      case 4:
        sasih = 'Sasih Kadasa';
        sebutanUrutan = 'Bulan Kesepuluh';
        break;
      case 5:
        sasih = 'Sasih Jhista / Jyestha';
        sebutanUrutan = 'Bulan Kesebelas';
        break;
      case 6:
        sasih = 'Sasih Sadha';
        sebutanUrutan = 'Bulan Kedua Belas';
        break;
      case 7:
        sasih = 'Sasih Kasa';
        sebutanUrutan = 'Bulan Pertama';
        break;
      case 8:
        sasih = 'Sasih Karo';
        sebutanUrutan = 'Bulan Kedua';
        break;
      case 9:
        sasih = 'Sasih Katiga';
        sebutanUrutan = 'Bulan Ketiga';
        break;
      case 10:
        sasih = 'Sasih Kapat';
        sebutanUrutan = 'Bulan Keempat';
        break;
      case 11:
        sasih = 'Sasih Kalima';
        sebutanUrutan = 'Bulan Kelima';
        break;
      case 12:
        sasih = 'Sasih Kanem';
        sebutanUrutan = 'Bulan Keenam';
        break;
    }

    return {
      'tahunSakaText': '$tahunSaka Saka',
      'rumusText': rumustext,
      'sasih': sasih,
      'sebutan': sebutanUrutan,
    };
  }

  @override
  Widget build(BuildContext context) {
    final wetonData = _hitungWetonLengkap(_selectedDate);
    final sakaData = _getSakaBaliLengkap(_selectedDate);

    String tglFormatted =
        '${_selectedDate.day} ${bulanMasehiGlobal[_selectedDate.month]} ${_selectedDate.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Weton & Saka Bali'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 2,
              child: ListTile(
                title: const Text('Pilih Tanggal:'),
                subtitle: Text(
                  tglFormatted,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: const Icon(Icons.calendar_month, color: Colors.teal),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.teal.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WETON JAWA',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hari Weton: ${wetonData['weton']}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tanggal Masehi: $tglFormatted',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Jumlah Neptu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    Text(
                      wetonData['pancasudaText'],
                      style: const TextStyle(fontSize: 14, height: 1.6),
                    ),
                    Text(
                      wetonData['saptaPancaText'],
                      style: const TextStyle(fontSize: 14, height: 1.6),
                    ),
                    Text(
                      wetonData['kamarokamText'],
                      style: const TextStyle(fontSize: 14, height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Watak Hari (Kamarokam)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wetonData['watakHari'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.amber.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'KALENDER SAKA BALI',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tahun Saka: ${sakaData['tahunSakaText']}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    const Text(
                      'Rumus Perhitungan Tahun:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Tahun Saka = Tahun Masehi - 78',
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• ${sakaData['rumusText']}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sasih (Bulan): ${sakaData['sasih']} (${sakaData['sebutan']})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

// Extension untuk kapitalisasi huruf pertama
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

//DATA PENGURUS / ANGGOTA (FULL CRUD)
class DataPengurusWidget extends StatelessWidget {
  final VoidCallback onRefresh;
  const DataPengurusWidget({super.key, required this.onRefresh});

  void _showFormAnggota(BuildContext context, {DocumentSnapshot? doc}) {
    final isEdit = doc != null;
    final Map<String, dynamic>? data = isEdit ? doc.data() as Map<String, dynamic>? : null;

    final nimController = TextEditingController(text: data?['nim'] ?? '');
    final namaController = TextEditingController(text: data?['nama'] ?? '');
    final jabatanController = TextEditingController(text: data?['jabatan'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Anggota' : 'Tambah Anggota Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nimController,
              decoration: const InputDecoration(labelText: 'NIM', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: jabatanController,
              decoration: const InputDecoration(labelText: 'Jabatan', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (namaController.text.isEmpty || nimController.text.isEmpty) return;

              if (isEdit) {
                await FirebaseFirestore.instance.collection('pengurus').doc(doc.id).update({
                  'nim': nimController.text,
                  'nama': namaController.text,
                  'jabatan': jabatanController.text,
                });
              } else {
                await FirebaseFirestore.instance.collection('pengurus').add({
                  'nim': nimController.text,
                  'nama': namaController.text,
                  'jabatan': jabatanController.text,
                  'createdAt': FieldValue.serverTimestamp(),
                });
              }

              if (context.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            child: Text(isEdit ? 'Update' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  void _hapusAnggota(BuildContext context, String docId, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Anggota'),
        content: Text('Yakin ingin menghapus "$nama" dari database?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('pengurus').doc(docId).delete();
              if (context.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kelas: $namaKelas', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Matkul: $mataKuliah'),
                  Text('Tugas: $tugas'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showFormAnggota(context),
            icon: const Icon(Icons.person_add),
            label: const Text('Tambah Anggota Kelas'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('pengurus').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Text('Belum ada data anggota di Firebase. Silakan klik "Tambah Anggota Kelas"'),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(data['nama'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('NIM: ${data['nim'] ?? '-'}\nJabatan: ${data['jabatan'] ?? '-'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.amber),
                              onPressed: () => _showFormAnggota(context, doc: doc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _hapusAnggota(context, doc.id, data['nama'] ?? ''),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//MENU KAS & KOMPUTASI (TAB BAR)
class MenuKasKomputasi extends StatefulWidget {
  const MenuKasKomputasi({super.key});

  @override
  State<MenuKasKomputasi> createState() => _MenuKasKomputasiState();
}

class _MenuKasKomputasiState extends State<MenuKasKomputasi> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kas & Komputasi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.amber,
          tabs: const [
            Tab(icon: Icon(Icons.add_card), text: 'Catat Transaksi'),
            Tab(icon: Icon(Icons.calculate), text: 'Hitung Iuran'),
            Tab(icon: Icon(Icons.summarize), text: 'Rekap Total'),
            Tab(icon: Icon(Icons.history), text: 'Riwayat'),
            Tab(icon: Icon(Icons.search), text: 'Cari Transaksi'),
            Tab(icon: Icon(Icons.format_list_numbered), text: 'Pengelompokan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TransaksiWidget(onRefresh: _refresh),
          HitungIuranWidget(onRefresh: _refresh),
          RekapTotalWidget(onRefresh: _refresh),
          RiwayatWidget(onRefresh: _refresh),
          CariTransaksiWidget(onRefresh: _refresh),
          PengelompokanInputWidget(onRefresh: _refresh),
        ],
      ),
    );
  }
}

// 3. TRANSAKSI (CREATE & READ)
class TransaksiWidget extends StatefulWidget {
  final VoidCallback onRefresh;
  const TransaksiWidget({super.key, required this.onRefresh});

  @override
  State<TransaksiWidget> createState() => _TransaksiWidgetState();
}

class _TransaksiWidgetState extends State<TransaksiWidget> {
  final _ketController = TextEditingController();
  final _nomController = TextEditingController();
  String _jenis = 'Pemasukan';
  bool _isLoading = false;
  DateTime _tanggalDipilih = DateTime.now(); // <-- Variabel Tanggal

  Future<void> _simpan() async {
    double nominal = double.tryParse(_nomController.text) ?? 0;
    if (nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari 0')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('transaksi').add({
        'jenis': _jenis.toLowerCase(),
        'keterangan': _ketController.text,
        'nominal': nominal,
        'createdAt': Timestamp.fromDate(_tanggalDipilih), // <-- Disimpan di sini
      });

      _ketController.clear();
      _nomController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi Berhasil Disimpan ke Database!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('transaksi').snapshots(),
            builder: (context, snapshot) {
              double totalSaldo = 0;
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  double nom = (data['nominal'] ?? 0).toDouble();
                  String jenis = (data['jenis'] ?? '').toString().toLowerCase();
                  if (jenis == 'pemasukan') {
                    totalSaldo += nom;
                  } else if (jenis == 'pengeluaran') {
                    totalSaldo -= nom;
                  }
                }
              }
              return Card(
                color: Colors.teal.shade100,
                child: ListTile(
                  title: const Text('Saldo Kas Saat Ini (Live Database)'),
                  trailing: Text(
                    'Rp ${formatRupiah(totalSaldo)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _jenis,
            items: ['Pemasukan', 'Pengeluaran']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => setState(() => _jenis = val!),
            decoration: const InputDecoration(labelText: 'Jenis Transaksi', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ketController,
            decoration: const InputDecoration(labelText: 'Keterangan', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nomController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Nominal (Rp)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),

          // --- TOMBOL PILIH TANGGAL ---
          ListTile(
            tileColor: Colors.teal.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            leading: const Icon(Icons.calendar_today, color: Colors.teal),
            title: const Text('Tanggal Transaksi'),
            subtitle: Text(
              '${_tanggalDipilih.day}/${_tanggalDipilih.month}/${_tanggalDipilih.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _tanggalDipilih,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _tanggalDipilih = picked);
              }
            },
          ),

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _simpan,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            child: _isLoading
                ? const SizedBox(
                    height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Simpan Transaksi Ke Firebase'),
          ),
        ],
      ),
    );
  }
}

// HITUNG IURAN
class HitungIuranWidget extends StatefulWidget {
  final VoidCallback onRefresh;
  const HitungIuranWidget({super.key, required this.onRefresh});

  @override
  State<HitungIuranWidget> createState() => _HitungIuranWidgetState();
}

class _HitungIuranWidgetState extends State<HitungIuranWidget> {
  final _targetController = TextEditingController();
  final _anggotaController = TextEditingController();
  final _mingguController = TextEditingController();
  String _hasil = '';

  void _hitung() {
    double target = double.tryParse(_targetController.text) ?? 0;
    int anggota = int.tryParse(_anggotaController.text) ?? 0;
    int minggu = int.tryParse(_mingguController.text) ?? 1;

    if (anggota <= 0 || minggu <= 0) return;

    double totalPerOrang = target / anggota;
    double iuranPerMinggu = totalPerOrang / minggu;

    setState(() {
      _hasil =
          '• Total Iuran per orang (seluruh periode): Rp ${formatRupiah(totalPerOrang)}\n\n'
          '• Iuran per orang per minggu: Rp ${formatRupiah(iuranPerMinggu)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          TextField(
            controller: _targetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Target Total Dana (Rp)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _anggotaController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Jumlah Anggota Kelas', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mingguController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Jumlah Minggu Penarikan', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _hitung,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            child: const Text('Hitung Iuran'),
          ),
          const SizedBox(height: 20),
          if (_hasil.isNotEmpty)
            Card(
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_hasil, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, height: 1.4)),
              ),
            ),
        ],
      ),
    );
  }
}

//REKAP TOTAL
class RekapTotalWidget extends StatelessWidget {
  final VoidCallback onRefresh;
  const RekapTotalWidget({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('transaksi').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        double totalMasuk = 0;
        double totalKeluar = 0;

        for (var doc in snapshot.data!.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          double nominal = (data['nominal'] ?? 0).toDouble();
          String jenis = (data['jenis'] ?? '').toString().toLowerCase();

          if (jenis == 'pemasukan') {
            totalMasuk += nominal;
          } else if (jenis == 'pengeluaran') {
            totalKeluar += nominal;
          }
        }

        double saldoAkhir = totalMasuk - totalKeluar;
        int saldoBulat = saldoAkhir.floor().abs();
        String ganjilGenap = (saldoBulat % 2 == 0) ? 'GENAP' : 'GANJIL';

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Card(child: ListTile(title: const Text('Total Pemasukan'), trailing: Text('Rp ${formatRupiah(totalMasuk)}'))),
              Card(child: ListTile(title: const Text('Total Pengeluaran'), trailing: Text('Rp ${formatRupiah(totalKeluar)}'))),
              Card(
                child: ListTile(
                  title: const Text('Saldo Akhir'),
                  trailing: Text('Rp ${formatRupiah(saldoAkhir)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              Card(child: ListTile(title: const Text('Keterangan Saldo'), trailing: Text('Nilai $ganjilGenap'))),
            ],
          ),
        );
      },
    );
  }
}

//RIWAYAT TRANSAKSI 
class RiwayatWidget extends StatelessWidget {
  final VoidCallback onRefresh;
  const RiwayatWidget({super.key, required this.onRefresh});

  void _editTransaksi(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ketController = TextEditingController(text: data['keterangan'] ?? '');
    final nomController = TextEditingController(text: (data['nominal'] ?? 0).toString());
    String jenis = (data['jenis'] ?? 'pemasukan').toString().capitalize();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Transaksi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: jenis,
              items: ['Pemasukan', 'Pengeluaran']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => jenis = val!,
              decoration: const InputDecoration(labelText: 'Jenis Transaksi', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ketController,
              decoration: const InputDecoration(labelText: 'Keterangan', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nomController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Nominal (Rp)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              double nom = double.tryParse(nomController.text) ?? 0;
              await FirebaseFirestore.instance.collection('transaksi').doc(doc.id).update({
                'jenis': jenis.toLowerCase(),
                'keterangan': ketController.text,
                'nominal': nom,
              });
              if (context.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('transaksi').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('Belum ada transaksi di database.'));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final jenis = (data['jenis'] ?? '').toString().toLowerCase();
            final keterangan = data['keterangan'] ?? '-';
            final nominal = (data['nominal'] ?? 0).toDouble();
            final isPemasukan = jenis == 'pemasukan';

            return ListTile(
              leading: Icon(
                isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
                color: isPemasukan ? Colors.green : Colors.red,
              ),
              title: Text(keterangan),
              subtitle: Text(jenis.toUpperCase()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Rp ${formatRupiah(nominal)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20, color: Colors.amber),
                    onPressed: () => _editTransaksi(context, doc),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// CARI TRANSAKSI
class CariTransaksiWidget extends StatefulWidget {
  final VoidCallback onRefresh;
  const CariTransaksiWidget({super.key, required this.onRefresh});

  @override
  State<CariTransaksiWidget> createState() => _CariTransaksiWidgetState();
}

class _CariTransaksiWidgetState extends State<CariTransaksiWidget> {
  String _keyword = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Cari Keterangan Transaksi',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (val) => setState(() => _keyword = val),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('transaksi').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  String ket = (data['keterangan'] ?? '').toString().toLowerCase();
                  return ket.contains(_keyword.toLowerCase());
                }).toList();

                if (docs.isEmpty) return const Center(child: Text('Tidak ada transaksi ditemukan.'));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final jenis = data['jenis'] ?? '';
                    final keterangan = data['keterangan'] ?? '';
                    final nominal = (data['nominal'] ?? 0).toDouble();

                    return ListTile(
                      title: Text(keterangan),
                      subtitle: Text(jenis.toString().toUpperCase()),
                      trailing: Text('Rp ${formatRupiah(nominal)}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//PENGELOMPOKAN INPUT
class PengelompokanInputWidget extends StatefulWidget {
  final VoidCallback onRefresh;
  const PengelompokanInputWidget({super.key, required this.onRefresh});

  @override
  State<PengelompokanInputWidget> createState() => _PengelompokanInputWidgetState();
}

class _PengelompokanInputWidgetState extends State<PengelompokanInputWidget> {
  final _inputController = TextEditingController();
  int _jumlahData = 0;
  List<String> _daftarNominalStr = [];

  void _prosesPengelompokan() {
    String text = _inputController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _jumlahData = 0;
        _daftarNominalStr = [];
      });
      return;
    }

    List<String> rawItems = text.split(RegExp(r'\s+'));
    RegExp angkaFormat = RegExp(r'^[0-9.:,\-]+$');
    List<String> hasilFiltered = rawItems.where((item) => item.isNotEmpty && angkaFormat.hasMatch(item)).toList();

    setState(() {
      _daftarNominalStr = hasilFiltered;
      _jumlahData = hasilFiltered.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          TextField(
            controller: _inputController,
            decoration: const InputDecoration(
              labelText: 'Masukkan data nominal / angka / tanggal',
              hintText: 'Contoh: tanggal 16-09-2027 membeli 19.8 kg',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _prosesPengelompokan,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            child: const Text('Hitung Pengelompokan'),
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.teal.shade100,
            child: ListTile(
              title: const Text('Jumlah Data Input:', style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text('$_jumlahData',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
            ),
          ),
          const SizedBox(height: 12),
          if (_daftarNominalStr.isNotEmpty) ...[
            const Text('Rincian Data Angka/Tanggal yang Terdeteksi:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List.generate(_daftarNominalStr.length, (index) {
              return Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.teal.shade50, child: Text('${index + 1}')),
                  title: Text('Item ke-${index + 1}'),
                  trailing: Text(_daftarNominalStr[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
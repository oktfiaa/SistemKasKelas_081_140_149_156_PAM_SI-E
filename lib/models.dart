import 'package:cloud_firestore/cloud_firestore.dart';

//MODEL PENGURUS KELAS(ke firebase)
class Pengurus {
  final String id;
  final String nim;
  final String nama;
  final String jabatan;

  Pengurus({
    this.id = '',
    required this.nim,
    required this.nama,
    required this.jabatan,
  });

  //mengubah data dari firebase (DocumentSnapshot) menjadi objek pengurus
  factory Pengurus.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Pengurus(
      id: doc.id,
      nim: data['nim'] ?? '',
      nama: data['nama'] ?? '',
      jabatan: data['jabatan'] ?? '',
    );
  }

  //mengubah objek pengurus menjadi map: disimpan dn diupdate ke firebase
  Map<String, dynamic> toMap() {
    return {
      'nim': nim,
      'nama': nama,
      'jabatan': jabatan,
    };
  }
}

//MODEL TRANSAKSI (terhubung ke firebase)
class Transaksi {
  final String id;
  final String jenis;
  final String keterangan;
  final double nominal;

  Transaksi({
    required this.id,
    required this.jenis,
    required this.keterangan,
    required this.nominal,
  });

  factory Transaksi.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Transaksi(
      id: doc.id,
      jenis: data['jenis'] ?? '',
      keterangan: data['keterangan'] ?? '',
      nominal: (data['nominal'] ?? 0).toDouble(),
    );
  }
}

//MODEL AKUN BENDAHARA
class AkunBendahara {
  final String _username;
  final String _password;

  AkunBendahara(this._username, this._password);

  String get username => _username;

  bool verifikasi(String usernameInput, String passwordInput) {
    return usernameInput == _username && passwordInput == _password;
  }
}

//HELPER FORMAT RUPIAH
String formatRupiah(double angka) {
  bool negatif = angka < 0;
  double absAngka = angka.abs();
  String angkaStr = absAngka.toStringAsFixed(2);

  List<String> bagian = angkaStr.split('.');
  String bagianBulat = bagian[0];
  String desimal = bagian[1];

  String hasilBulat = '';
  int hitung = 0;

  for (int i = bagianBulat.length - 1; i >= 0; i--) {
    hasilBulat = bagianBulat[i] + hasilBulat;
    hitung++;
    if (hitung % 3 == 0 && i != 0) {
      hasilBulat = '.$hasilBulat';
    }
  }

  String hasilAkhir = '$hasilBulat,$desimal';
  return negatif ? '-$hasilAkhir' : hasilAkhir;
}

//DATA & KONSTANTA GLOBAL
final AkunBendahara akunBendahara = AkunBendahara('bendahara', '12345');

const String namaKelas = 'Kelas PAM SI-E';
const String mataKuliah = 'Pemrograman Aplikasi Mobile';
const String tugas = 'Sistem Kas Kelas';

final List<String> bulanMasehiGlobal = [
  '','Januari','Februari','Maret','April','Mei','Juni','Juli',
  'Agustus','September','Oktober','November','Desember',
];
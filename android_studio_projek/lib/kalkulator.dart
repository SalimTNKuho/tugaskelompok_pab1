import 'dart:async';
import 'dart:io';

/// Kelas [Kalkulator] untuk melakukan operasi matematika dasar
/// baik secara sinkron maupun asinkron.
class Kalkulator {
  /// Penjumlahan dua angka
  num tambah(num a, num b) => a + b;

  /// Pengurangan dua angka
  num kurang(num a, num b) => a - b;

  /// Perkalian dua angka
  num kali(num a, num b) => a * b;

  /// Pembagian dua angka dengan penanganan exception untuk pembagian dengan nol
  double bagi(num a, num b) {
    if (b == 0) {
      throw ArgumentError('Tidak dapat membagi dengan angka nol (0).');
    }
    return a / b;
  }

  /// Operasi aritmatika secara asinkron dengan simulasi delay dan penanganan exception
  Future<num> hitungAsync({
    required num a,
    required num b,
    required String operasi,
    Duration delay = const Duration(seconds: 1),
  }) async {
    await Future.delayed(delay);

    switch (operasi.toLowerCase()) {
      case 'tambah':
      case '+':
      case '1':
        return tambah(a, b);
      case 'kurang':
      case '-':
      case '2':
        return kurang(a, b);
      case 'kali':
      case '*':
      case '3':
        return kali(a, b);
      case 'bagi':
      case '/':
      case '4':
        return bagi(a, b);
      default:
        throw ArgumentError('Operasi "$operasi" tidak dikenali.');
    }
  }
}

void main() async {
  final kalkulator = Kalkulator();

  while (true) {
    print('\n=================================');
    print('   APLIKASI KALKULATOR INTERAKTIF');
    print('=================================');
    print('Pilih Operasi Matematika:');
    print('1. Penjumlahan (+)');
    print('2. Pengurangan (-)');
    print('3. Perkalian (*)');
    print('4. Pembagian (/)');
    print('5. Hitung Asinkron (Dengan Delay 1 Detik)');
    print('6. Keluar');
    print('---------------------------------');
    stdout.write('Masukkan pilihan Anda (1-6): ');

    String? pilihan = stdin.readLineSync()?.trim();

    if (pilihan == '6' || pilihan?.toLowerCase() == 'keluar') {
      print('\nTerima kasih telah menggunakan kalkulator!');
      break;
    }

    if (pilihan != '1' &&
        pilihan != '2' &&
        pilihan != '3' &&
        pilihan != '4' &&
        pilihan != '5') {
      print('>>> Pilihan tidak valid! Silakan pilih angka 1 - 6.');
      continue;
    }

    // Input Angka Pertama
    stdout.write('Masukkan angka pertama: ');
    String? input1 = stdin.readLineSync();
    double? angka1 = double.tryParse(input1 ?? '');

    if (angka1 == null) {
      print('>>> Input angka pertama tidak valid!');
      continue;
    }

    // Input Angka Kedua
    stdout.write('Masukkan angka kedua: ');
    String? input2 = stdin.readLineSync();
    double? angka2 = double.tryParse(input2 ?? '');

    if (angka2 == null) {
      print('>>> Input angka kedua tidak valid!');
      continue;
    }

    // Eksekusi Operasi Perhitungan
    try {
      num hasil;
      switch (pilihan) {
        case '1':
          hasil = kalkulator.tambah(angka1, angka2);
          print('\n[Hasil] $angka1 + $angka2 = $hasil');
          break;
        case '2':
          hasil = kalkulator.kurang(angka1, angka2);
          print('\n[Hasil] $angka1 - $angka2 = $hasil');
          break;
        case '3':
          hasil = kalkulator.kali(angka1, angka2);
          print('\n[Hasil] $angka1 * $angka2 = $hasil');
          break;
        case '4':
          hasil = kalkulator.bagi(angka1, angka2);
          print('\n[Hasil] $angka1 / $angka2 = $hasil');
          break;
        case '5':
          stdout.write('Pilih simbol operasi untuk asinkron (+, -, *, /): ');
          String? ops = stdin.readLineSync()?.trim();
          print('Memproses perhitungan secara asinkron (mohon tunggu 1 detik)...');
          hasil = await kalkulator.hitungAsync(
            a: angka1,
            b: angka2,
            operasi: ops ?? '+',
          );
          print('\n[Hasil Asinkron] $angka1 $ops $angka2 = $hasil');
          break;
      }
    } catch (e) {
      print('\n[Error] Terjadi kesalahan: $e');
    }
  }
}

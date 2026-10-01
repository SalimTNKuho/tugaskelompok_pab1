import 'package:android_studio_projek/kalkulator.dart';
import 'package:test/test.dart';

void main() {
  group('Kalkulator Tests', () {
    late Kalkulator kalkulator;

    setUp(() {
      kalkulator = Kalkulator();
    });

    test('Penjumlahan', () {
      expect(kalkulator.tambah(10, 5), equals(15));
    });

    test('Pengurangan', () {
      expect(kalkulator.kurang(10, 5), equals(5));
    });

    test('Perkalian', () {
      expect(kalkulator.kali(10, 5), equals(50));
    });

    test('Pembagian Normal', () {
      expect(kalkulator.bagi(10, 5), equals(2.0));
    });

    test('Pembagian dengan Nol melempar ArgumentError', () {
      expect(() => kalkulator.bagi(10, 0), throwsArgumentError);
    });

    test('Hitung Async berhasil', () async {
      final hasil = await kalkulator.hitungAsync(a: 20, b: 4, operasi: '+');
      expect(hasil, equals(24));
    });

    test('Hitung Async error pembagian nol', () async {
      expect(
        () async => await kalkulator.hitungAsync(a: 10, b: 0, operasi: 'bagi'),
        throwsArgumentError,
      );
    });
  });
}

# hitung.

Aplikasi kalkulator Flutter yang responsif untuk Android dan browser desktop/mobile.

## Menjalankan

Jalankan perintah dari folder `android_studio_projek`:

```sh
flutter pub get
flutter run -d chrome       # Web di PC
flutter run                 # Android dengan emulator/perangkat terhubung
```

Build untuk web dan Android:

```sh
flutter build web --release
flutter build apk --release
```

## Fitur

- Operasi tambah, kurang, kali, bagi, persen, dan ubah tanda.
- Mode hitung standar dan asinkron.
- Input keyboard pada PC: angka, `+`, `-`, `*`, `/`, `Enter`, `Backspace`, dan `Esc`.
- Tampilan adaptif untuk layar ponsel dan desktop.

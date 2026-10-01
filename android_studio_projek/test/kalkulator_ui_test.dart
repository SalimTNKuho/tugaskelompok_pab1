import 'dart:ui';

import 'package:android_studio_projek/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('kalkulator menghitung dari keypad', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('7'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('='));
    await tester.pumpAndSettle();

    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('kalkulator menampilkan error saat dibagi nol', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('8'));
    await tester.tap(find.text('÷'));
    await tester.tap(find.text('0').last);
    await tester.tap(find.text('='));
    await tester.pumpAndSettle();

    expect(find.text('Error'), findsOneWidget);
  });

  testWidgets('mode asinkron menghitung melalui kalkulator', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('Async'));
    await tester.tap(find.text('6'));
    await tester.tap(find.text('×'));
    await tester.tap(find.text('7'));
    await tester.tap(find.text('='));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('42'), findsOneWidget);
  });
}

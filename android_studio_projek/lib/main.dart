import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'kalkulator.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF10111A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9A83FF),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  static const _accent = Color(0xFFB8A6FF);
  static const _muted = Color(0xFF9697A8);

  final _calculator = Kalkulator();
  String _display = '0';
  String _history = '';
  String? _operator;
  num? _firstOperand;
  bool _replaceDisplay = false;
  bool _asyncMode = false;
  bool _isCalculating = false;

  void _inputDigit(String digit) {
    if (_isCalculating) return;
    setState(() {
      if (_replaceDisplay || _display == '0') {
        _display = digit;
        _replaceDisplay = false;
      } else if (_display.length < 14) {
        _display += digit;
      }
    });
  }

  void _inputDecimal() {
    if (_isCalculating) return;
    setState(() {
      if (_replaceDisplay) {
        _display = '0.';
        _replaceDisplay = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _history = '';
      _operator = null;
      _firstOperand = null;
      _replaceDisplay = false;
      _isCalculating = false;
    });
  }

  void _backspace() {
    if (_isCalculating) return;
    setState(() {
      if (_replaceDisplay) return;
      _display = _display.length <= 1
          ? '0'
          : _display.substring(0, _display.length - 1);
      if (_display == '-') _display = '0';
    });
  }

  void _toggleSign() {
    if (_isCalculating || _display == '0') return;
    setState(() {
      _display = _display.startsWith('-')
          ? _display.substring(1)
          : '-$_display';
    });
  }

  void _percent() {
    if (_isCalculating) return;
    final value = num.tryParse(_display);
    if (value == null) return;
    setState(() {
      _display = _format(value / 100);
      _replaceDisplay = true;
    });
  }

  void _selectOperator(String operator) {
    if (_isCalculating) return;
    final value = num.tryParse(_display);
    if (value == null) return;
    setState(() {
      _firstOperand = value;
      _operator = operator;
      _history = '${_format(value)} $operator';
      _replaceDisplay = true;
    });
  }

  Future<void> _equals() async {
    final first = _firstOperand;
    final operator = _operator;
    final second = num.tryParse(_display);
    if (first == null || operator == null || second == null || _isCalculating) {
      return;
    }

    setState(() {
      _isCalculating = _asyncMode;
      _history = '${_format(first)} $operator ${_format(second)} =';
    });

    try {
      final num result;
      if (_asyncMode) {
        result = await _calculator.hitungAsync(
          a: first,
          b: second,
          operasi: _operationName(operator),
          delay: const Duration(milliseconds: 650),
        );
      } else {
        result = switch (operator) {
          '+' => _calculator.tambah(first, second),
          '−' => _calculator.kurang(first, second),
          '×' => _calculator.kali(first, second),
          '÷' => _calculator.bagi(first, second),
          _ => throw ArgumentError('Operasi tidak dikenali: $operator'),
        };
      }
      if (!mounted) return;
      setState(() {
        _display = _format(result);
        _firstOperand = null;
        _operator = null;
        _replaceDisplay = true;
        _isCalculating = false;
      });
    } on ArgumentError catch (error) {
      if (!mounted) return;
      setState(() {
        _display = 'Error';
        _firstOperand = null;
        _operator = null;
        _replaceDisplay = true;
        _isCalculating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message?.toString() ?? 'Perhitungan gagal'),
        ),
      );
    }
  }

  String _operationName(String operator) => switch (operator) {
    '+' => 'tambah',
    '−' => 'kurang',
    '×' => 'kali',
    '÷' => 'bagi',
    _ => operator,
  };

  String _format(num value) {
    if (!value.isFinite) return 'Error';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsPrecision(10).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  KeyEventResult _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final label = key.keyLabel;
    if (RegExp(r'^\d$').hasMatch(label)) {
      _inputDigit(label);
    } else if (label == '.') {
      _inputDecimal();
    } else if (label == '+') {
      _selectOperator('+');
    } else if (label == '-') {
      _selectOperator('−');
    } else if (label == '*') {
      _selectOperator('×');
    } else if (label == '/') {
      _selectOperator('÷');
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        label == '=') {
      _equals();
    } else if (key == LogicalKeyboardKey.backspace) {
      _backspace();
    } else if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.delete) {
      _clear();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) => _handleKey(event),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.8, -1),
              radius: 1.5,
              colors: [Color(0xFF292344), Color(0xFF10111A)],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 720;
                final calculator = _buildCalculator();
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? 36 : 20,
                        vertical: wide ? 28 : 20,
                      ),
                      child: wide
                          ? Row(
                              children: [
                                Expanded(child: _buildIntro()),
                                const SizedBox(width: 56),
                                SizedBox(width: 430, child: calculator),
                              ],
                            )
                          : Column(
                              children: [
                                _buildHeader(),
                                const SizedBox(height: 12),
                                Expanded(child: calculator),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBrand(),
        const SizedBox(height: 42),
        const Text(
          'Hitung dengan\nlebih sederhana.',
          style: TextStyle(
            fontSize: 48,
            height: 1.12,
            letterSpacing: -1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Kalkulator praktis untuk semua perangkat.',
          style: TextStyle(fontSize: 17, color: _muted),
        ),
        const SizedBox(height: 34),
        Row(
          children: [
            _featurePill(Icons.bolt_rounded, 'Hitung cepat'),
            const SizedBox(width: 10),
            _featurePill(Icons.devices_rounded, 'Responsif'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [_buildBrand(), _featurePill(Icons.devices_rounded, 'Responsif')],
  );

  Widget _buildBrand() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.calculate_rounded, color: _accent),
      ),
      const SizedBox(width: 12),
      const Text(
        'hitung.',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
      ),
    ],
  );

  Widget _featurePill(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: _accent),
        const SizedBox(width: 7),
        Text(label, style: const TextStyle(fontSize: 12, color: _muted)),
      ],
    ),
  );

  Widget _buildCalculator() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1B27).withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 48,
          offset: const Offset(0, 24),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            const Text(
              'KALKULATOR',
              style: TextStyle(
                color: _muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            _modeSwitch(),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xFF11121B),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 24,
                  child: Text(
                    _isCalculating ? 'Memproses...' : _history,
                    style: const TextStyle(color: _muted, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _display,
                    key: const ValueKey('calculator-display'),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: _display.length > 10 ? 38 : 48,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(flex: 5, child: _buildKeypad()),
      ],
    ),
  );

  Widget _modeSwitch() => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: const Color(0xFF11121B),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [_modeButton('Standar', false), _modeButton('Async', true)],
    ),
  );

  Widget _modeButton(String label, bool async) {
    final selected = _asyncMode == async;
    return GestureDetector(
      onTap: () => setState(() => _asyncMode = async),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? _accent.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _accent : _muted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    const rows = [
      ['AC', '±', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '−'],
      ['1', '2', '3', '+'],
    ];
    return Column(
      children: [
        for (final row in rows) ...[
          Expanded(
            child: Row(
              children: [
                for (final label in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: _key(label),
                    ),
                  ),
              ],
            ),
          ),
        ],
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _key('0'),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _key('.'),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _key('='),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _key(String label) {
    final operator = const ['÷', '×', '−', '+', '='].contains(label);
    final utility = const ['AC', '±', '%'].contains(label);
    final highlighted = label == '=';
    return Material(
      color: highlighted
          ? _accent
          : operator
          ? _accent.withValues(alpha: 0.13)
          : utility
          ? const Color(0xFF292A38)
          : const Color(0xFF22232F),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () => _pressKey(label),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: highlighted
                  ? const Color(0xFF171321)
                  : utility
                  ? _accent
                  : Colors.white,
              fontSize: label == 'AC' ? 17 : 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _pressKey(String label) {
    if (RegExp(r'^\d$').hasMatch(label)) {
      _inputDigit(label);
    } else {
      switch (label) {
        case '.':
          _inputDecimal();
        case 'AC':
          _clear();
        case '±':
          _toggleSign();
        case '%':
          _percent();
        case '=':
          _equals();
        default:
          _selectOperator(label);
      }
    }
  }
}

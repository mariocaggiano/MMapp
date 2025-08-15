import 'package:flutter/material.dart';
import 'api.dart';
import 'dart:math' as math;

class WeightPage extends StatefulWidget {
  final Api api;
  const WeightPage({super.key, required this.api});

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  bool _loading = true;
  List<dynamic> _weights = [];
  final TextEditingController _input = TextEditingController();

  Future<void> _load() async {
    final list = await widget.api.listWeights(range: '30d');
    setState(() { _weights = list; _loading = false; });
  }

  Future<void> _add() async {
    final v = double.tryParse(_input.text.replaceAll(',', '.'));
    if (v == null) return;
    final today = DateTime.now();
    await widget.api.addWeight(date: today.toIso8601String().substring(0,10), weightKg: v);
    _input.clear();
    _load();
  }

  @override
  void initState() { super.initState(); _load(); }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final items = List<Map<String,dynamic>>.from(_weights);
    items.sort((a,b) => (b['date'] as String).compareTo(a['date'] as String));
    final values = items.reversed.map((e) => (e['weight_kg'] as num).toDouble()).toList();
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Aggiungi peso di oggi', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextField(
                      controller: _input,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Peso (kg)'),
                    )),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: _add, child: const Text('Salva'))
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (values.isNotEmpty) Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ultimi 30 giorni', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 120, child: _MiniChart(values: values)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Storico (recenti)', style: TextStyle(fontSize: 16)),
          for (final e in items) ListTile(
            title: Text(e['date']),
            trailing: Text('${e['weight_kg']} kg'),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _MiniChart extends StatelessWidget {
  final List<double> values;
  const _MiniChart({required this.values});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ChartPainter(values),
      child: Container(),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> values;
  _ChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);
    final dx = size.width / (values.length - 1).clamp(1, 999);
    Path path = Path();
    for (int i=0;i<values.length;i++) {
      final x = i * dx;
      final y = size.height - ((values[i] - minV) / range) * size.height;
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => true;
}

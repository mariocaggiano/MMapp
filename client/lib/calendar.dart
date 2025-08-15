import 'package:flutter/material.dart';
import 'api.dart';

class CalendarPage extends StatefulWidget {
  final Api api;
  const CalendarPage({super.key, required this.api});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool _loading = true;
  Map<String, List<dynamic>> _byDay = {};

  Future<void> _load() async {
    final sessions = await widget.api.listSessions();
    final Map<String, List<dynamic>> grouped = {};
    for (final s in sessions) {
      final d = DateTime.parse(s['date']).toLocal();
      final key = DateTime(d.year, d.month, d.day).toIso8601String();
      grouped.putIfAbsent(key, () => []).add(s);
    }
    setState(() { _byDay = grouped; _loading = false; });
  }

  @override
  void initState() { super.initState(); _load(); }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final days = _byDay.keys.toList()..sort((a,b) => b.compareTo(a));
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: days.length,
        itemBuilder: (ctx, i) {
          final key = days[i];
          final day = DateTime.parse(key);
          final list = _byDay[key]!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${day.day}/${day.month}/${day.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    for (final s in list) ListTile(
                      title: Text('${DateTime.parse(s['date']).toLocal().hour.toString().padLeft(2,'0')}:${DateTime.parse(s['date']).toLocal().minute.toString().padLeft(2,'0')}  •  ${s['duration_min']} min'),
                      subtitle: Text('RPE: ${s['intensity_rpe'] ?? '-'}  •  ${((s['disciplines'] ?? []) as List).join(', ')}'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

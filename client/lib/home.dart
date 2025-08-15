import 'package:flutter/material.dart';
import 'api.dart';
import 'new_session.dart';

class HomePage extends StatefulWidget {
  final Api api;
  const HomePage({super.key, required this.api});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _sessions = [];
  Map<String, dynamic>? _overview;
  bool _loading = true;

  Future<void> _load() async {
    final me = await widget.api.getMe();
    final ss = await widget.api.listSessions();
    final ov = await widget.api.statsOverview();
    setState(() {
      _sessions = ss;
      _overview = ov;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MMA Tracker')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_overview != null) Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Questa settimana', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Minuti totali: ${_overview!['totalMinutes']}'),
                    Text('Striking: ${_overview!['byDiscipline']['striking']}  •  Grappling: ${_overview!['byDiscipline']['grappling']}'),
                    Text('Sparring: ${_overview!['byDiscipline']['sparring']}  •  Conditioning: ${_overview!['byDiscipline']['conditioning']}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Allenamenti recenti', style: TextStyle(fontSize: 16)),
            for (final s in _sessions) ListTile(
              title: Text('${DateTime.parse(s['date']).toLocal()}'),
              subtitle: Text('Durata: ${s['duration_min']} min  •  RPE: ${s['intensity_rpe'] ?? '-'}'),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewSessionPage(api: widget.api)));
          if (created == true) _load();
        },
        label: const Text('+ Allenamento'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'api.dart';

class NewSessionPage extends StatefulWidget {
  final Api api;
  const NewSessionPage({super.key, required this.api});

  @override
  State<NewSessionPage> createState() => _NewSessionPageState();
}

class _NewSessionPageState extends State<NewSessionPage> {
  DateTime _date = DateTime.now();
  int _duration = 60;
  int _rpe = 7;
  final Set<String> _disciplines = {'striking'};
  final TextEditingController _notes = TextEditingController();

  Future<void> _save() async {
    await widget.api.createSession(
      dateIso: _date.toUtc().toIso8601String(),
      durationMin: _duration,
      intensityRpe: _rpe,
      disciplines: _disciplines.toList(),
      notes: _notes.text.isEmpty ? null : _notes.text,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuovo allenamento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text('Data & ora'),
              subtitle: Text(_date.toLocal().toString()),
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100));
                if (d != null) {
                  final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date));
                  setState(() => _date = DateTime(d.year, d.month, d.day, t?.hour ?? 12, t?.minute ?? 0));
                }
              },
            ),
            Row(children: [
              Expanded(child: TextFormField(
                initialValue: _duration.toString(),
                decoration: const InputDecoration(labelText: 'Durata (min)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => _duration = int.tryParse(v) ?? 60,
              )),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(
                initialValue: _rpe.toString(),
                decoration: const InputDecoration(labelText: 'Intensità RPE (1-10)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => _rpe = int.tryParse(v) ?? 7,
              )),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, children: [
              for (final d in ['striking','grappling','sparring','conditioning'])
                FilterChip(
                  label: Text(d),
                  selected: _disciplines.contains(d),
                  onSelected: (s) => setState(() { if (s) _disciplines.add(d); else _disciplines.remove(d); }),
                )
            ]),
            const SizedBox(height: 12),
            TextField(controller: _notes, decoration: const InputDecoration(labelText: 'Note'), maxLines: 3),
            const Spacer(),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('Salva'))),
          ],
        ),
      ),
    );
  }
}

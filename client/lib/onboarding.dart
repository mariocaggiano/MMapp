import 'package:flutter/material.dart';
import 'api.dart';

class OnboardingPage extends StatefulWidget {
  final Api api;
  const OnboardingPage({super.key, required this.api});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  String _displayName = '';
  String _role = 'amateur'; // amateur | semi_pro | pro | coach
  String _weightClass = '';

  Future<void> _finish() async {
    await widget.api.updateMe(displayName: _displayName, weightClass: _weightClass);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final roles = const {
      'amateur': 'Amatore',
      'semi_pro': 'Semi-pro',
      'pro': 'Fighter Pro',
      'coach': 'Coach',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Benvenuto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Crea profilo', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Nome visualizzato'),
              onChanged: (v) => _displayName = v,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(labelText: 'Ruolo'),
              items: roles.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: (v) => setState(() => _role = v ?? 'amateur'),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'Categoria di peso (es. Lightweight)'),
              onChanged: (v) => _weightClass = v,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _finish, child: const Text('Inizia')),
            )
          ],
        ),
      ),
    );
  }
}

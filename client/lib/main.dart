import 'package:flutter/material.dart';
import 'api.dart';
import 'onboarding.dart';
import 'app_shell.dart';

void main() {
  runApp(const MMAApp());
}

class MMAApp extends StatelessWidget {
  const MMAApp({super.key});
  @override
  Widget build(BuildContext context) {
    final api = Api();
    return MaterialApp(
      title: 'MMA Tracker',
      theme: ThemeData.dark(useMaterial3: true),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (_) => OnboardingPage(api: api),
        '/home': (_) => AppShell(api: api),
      },
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {
  final String base;
  final String devUserId;
  Api({this.base = 'http://localhost:3000', this.devUserId = '00000000-0000-0000-0000-000000000001'});

  Map<String, String> _headers() => {
    'Authorization': 'Bearer dev',
    'X-User-Id': devUserId,
    'Content-Type': 'application/json',
  };

  Future<Map<String, dynamic>> getMe() async {
    final res = await http.get(Uri.parse('$base/api/v1/me'), headers: _headers());
    return jsonDecode(res.body) as Map<String, dynamic>;
    }

  Future<void> updateMe({String? displayName, String? weightClass}) async {
    await http.patch(Uri.parse('$base/api/v1/me'), headers: _headers(), body: jsonEncode({
      if (displayName != null) 'displayName': displayName,
      if (weightClass != null) 'weightClass': weightClass,
    }));
  }

  Future<List<dynamic>> listSessions() async {
    final res = await http.get(Uri.parse('$base/api/v1/sessions'), headers: _headers());
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createSession({required String dateIso, required int durationMin, int? intensityRpe, List<String>? disciplines, String? notes}) async {
    final res = await http.post(Uri.parse('$base/api/v1/sessions'),
      headers: _headers(),
      body: jsonEncode({
        'date': dateIso,
        'durationMin': durationMin,
        if (intensityRpe != null) 'intensityRpe': intensityRpe,
        if (disciplines != null) 'disciplines': disciplines,
        if (notes != null) 'notes': notes,
      }));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> statsOverview() async {
    final res = await http.get(Uri.parse('$base/api/v1/stats/overview'), headers: _headers());
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}


Future<Map<String, dynamic>> addWeight({required String date, required double weightKg}) async {
  final res = await http.post(Uri.parse('$base/api/v1/weights'),
    headers: _headers(),
    body: jsonEncode({'date': date, 'weightKg': weightKg}));
  return jsonDecode(res.body) as Map<String, dynamic>;
}

Future<List<dynamic>> listWeights({String range='30d'}) async {
  final res = await http.get(Uri.parse('$base/api/v1/weights?range=$range'), headers: _headers());
  return jsonDecode(res.body) as List<dynamic>;
}

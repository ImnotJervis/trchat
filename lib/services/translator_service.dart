import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslatorService {
  static const String _apiKey = 'AIzaSyC4RXLwgF338sWao0a5Oi1vjMR7dihq31s';

  static Future<String> translate({
    required String text,
    required String targetLang,
  }) async {
    final url = Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$_apiKey');
    final response = await http.post(
      url,
      body: json.encode({
        'q': text,
        'target': targetLang,
        'format': 'text',
      }),
      headers: {'Content-Type': 'application/json'},
    );

    final jsonBody = json.decode(response.body);
    return jsonBody['data']['translations'][0]['translatedText'];
  }
}

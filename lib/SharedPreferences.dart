import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static Future<void> saveJokes(List<Map<String, String>> jokes) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedJokes = jsonEncode(jokes);
    await prefs.setString('jokes', encodedJokes);
  }

  static Future<List<Map<String, String>>> getJokes() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedJokes = prefs.getString('jokes');
    if (encodedJokes != null) {
      final decodedJokes = jsonDecode(encodedJokes) as List<dynamic>;
      return decodedJokes.map((joke) => Map<String, String>.from(joke)).toList();
    }
    return [];
  }

  static Future<void> clearJokes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jokes');
  }
}

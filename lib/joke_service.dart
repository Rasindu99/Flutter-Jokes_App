import 'package:dio/dio.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // For checking internet connection

class JokeService {
  final Dio _dio = Dio();
  final String _cacheKey = "cachedJokes";

  Future<List<Map<String, dynamic>>> fetchJokes() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      final jokes = await fetchJokesRaw();

      await _cacheJokes(jokes);

      return jokes;
    } catch (e) {
      final cachedJokes = await _getCachedJokes();
      if (cachedJokes != null && cachedJokes.isNotEmpty) {
        return cachedJokes;
      } else {
        throw Exception('No internet and no cached jokes available.');
      }
    }
  }

  /// Fetch jokes directly from the API
  Future<List<Map<String, dynamic>>> fetchJokesRaw() async {
    final response = await _dio.get(
      "https://v2.jokeapi.dev/joke/Programming,Christmas?blacklistFlags=nsfw,religious,racist&amount=4",
    );

    if (response.statusCode == 200) {
      final List<dynamic> jokesJson = response.data['jokes'];
      return jokesJson.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load jokes');
    }
  }

  Future<List<Map<String, dynamic>>?> _getCachedJokes() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);

    if (cachedData != null) {
      final List<dynamic> jokesList = jsonDecode(cachedData);
      return jokesList.cast<Map<String, dynamic>>();
    }

    return null;
  }

  Future<void> _cacheJokes(List<Map<String, dynamic>> jokes) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedJokes = jsonEncode(jokes);
    await prefs.setString(_cacheKey, encodedJokes);
    print("Jokes cached successfully.");
  }
}

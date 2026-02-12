import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie.dart';

class ApiService {
  static const String apiKey = "1fe4cc52ff59c1701cbc478709b0e3bf";
  static const String baseUrl = "https://api.themoviedb.org/3";
  static const Duration _timeout = Duration(seconds: 8);

  Exception _mapError(Object e) {
    return Exception("Không thể tải dữ liệu. Vui lòng thử lại.");
  }

  Future<List<Movie>> getPopularMovies() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              "$baseUrl/movie/popular?api_key=$apiKey&language=en-US&page=1",
            ),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data["results"];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception("Lỗi ${response.statusCode}: Không thể tải phim");
      }
    } catch (e) {
      throw _mapError(e);
    }
  }

  Future<String?> getTrailerUrl(int movieId) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              "$baseUrl/movie/$movieId/videos?api_key=$apiKey&language=en-US",
            ),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final List results = data["results"] ?? [];
      final trailer = results.whereType<Map<String, dynamic>>().firstWhere(
        (v) =>
            v['site']?.toString().toLowerCase() == 'youtube' &&
            v['type']?.toString().toLowerCase() == 'trailer',
        orElse: () => {},
      );

      final key = trailer['key']?.toString();
      if (key == null || key.isEmpty) return null;
      return 'https://www.youtube.com/watch?v=$key';
    } catch (_) {
      return null;
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              "$baseUrl/search/movie?api_key=$apiKey&query=${Uri.encodeQueryComponent(query)}&language=en-US&page=1&include_adult=false",
            ),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data["results"];
        return results.map((e) => Movie.fromJson(e)).toList();
      } else {
        throw Exception("Lỗi ${response.statusCode}: Không thể tìm phim");
      }
    } catch (e) {
      throw _mapError(e);
    }
  }
}

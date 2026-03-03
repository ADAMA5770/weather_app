// lib/services/weather_service.dart

import 'package:dio/dio.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  // ⚠️ REMPLACE PAR TA CLÉ API OPENWEATHER ⚠️
  // Inscription gratuite sur https://openweathermap.org/api
  static const String _apiKey = '624c0388cee760de6db04e35c0ea012c';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Les 5 villes qu'on va récupérer
  static const List<String> cities = [
    'Dakar',
    'Paris',
    'New York',
    'Tokyo',
    'London',
  ];

  Future<WeatherModel> getWeatherForCity(String city) async {
    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'q': city,
          'appid': _apiKey,
          'units': 'metric', // Celsius
          'lang': 'fr',      // Descriptions en français
        },
      );
      return WeatherModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Timeout : vérifiez votre connexion internet');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Clé API invalide. Vérifiez votre clé OpenWeather.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Ville "$city" introuvable.');
      }
      throw Exception('Erreur réseau : ${e.message}');
    }
  }

  Future<List<WeatherModel>> getAllCitiesWeather() async {
    List<WeatherModel> results = [];
    for (String city in cities) {
      final weather = await getWeatherForCity(city);
      results.add(weather);
      // Petite pause entre chaque appel pour ne pas surcharger l'API
      await Future.delayed(const Duration(milliseconds: 500));
    }
    return results;
  }
}

// lib/screens/results_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';
import 'city_detail_screen.dart';

class ResultsScreen extends StatelessWidget {
  final List<WeatherModel> weatherData;

  const ResultsScreen({super.key, required this.weatherData});

  Color _getTempColor(double temp) {
    if (temp < 0) return const Color(0xFF1565C0);
    if (temp < 10) return const Color(0xFF1E88E5);
    if (temp < 20) return const Color(0xFF43A047);
    if (temp < 30) return const Color(0xFFFF8F00);
    return const Color(0xFFE53935);
  }

  String _getTempEmoji(double temp) {
    if (temp < 0) return '🥶';
    if (temp < 10) return '🧥';
    if (temp < 20) return '😊';
    if (temp < 30) return '☀️';
    return '🔥';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F4FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // AppBar stylée
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: isDark
                ? const Color(0xFF1A1F2E)
                : const Color(0xFF1565C0),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🌍', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${weatherData.length} villes',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 56, bottom: 14),
              title: Text(
                'Météo Mondiale',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF1A1F2E),
                            const Color(0xFF0D1117)
                          ]
                        : [
                            const Color(0xFF1565C0),
                            const Color(0xFF42A5F5)
                          ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 56, bottom: 38),
                    child: Text(
                      'Clique sur une ville pour les détails 👆',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Liste des cartes
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildWeatherCard(context, weatherData[index], index),
                childCount: weatherData.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(
      BuildContext context, WeatherModel weather, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tempColor = _getTempColor(weather.temperature);
    final tempEmoji = _getTempEmoji(weather.temperature);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CityDetailScreen(weather: weather)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: tempColor.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: tempColor.withOpacity(0.18),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Bande colorée à gauche
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        tempColor,
                        tempColor.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),

                // Contenu
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Numéro
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: tempColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: tempColor,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Icône météo
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.network(
                            weather.iconUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Text(tempEmoji,
                                style: const TextStyle(fontSize: 36)),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Infos ville
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Nom + pays
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      weather.cityName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      weather.country,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${weather.description[0].toUpperCase()}${weather.description.substring(1)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              // Chips humidité + vent
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  _buildInfoChip(
                                      context, '💧', '${weather.humidity}%'),
                                  _buildInfoChip(context, '💨',
                                      '${weather.windSpeed.round()}m/s'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Température
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(tempEmoji,
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 2),
                            Text(
                              weather.tempFormatted,
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: tempColor,
                              ),
                            ),
                            Text(
                              weather.feelsLikeFormatted,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(Icons.chevron_right_rounded,
                                color: Colors.grey.withOpacity(0.5), size: 18),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$icon $text',
        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}

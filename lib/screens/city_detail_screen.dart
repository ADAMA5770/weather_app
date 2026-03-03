// lib/screens/city_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/weather_model.dart';

class CityDetailScreen extends StatelessWidget {
  final WeatherModel weather;

  const CityDetailScreen({super.key, required this.weather});

  Color get _tempColor {
    final t = weather.temperature;
    if (t < 0) return const Color(0xFF1565C0);
    if (t < 10) return const Color(0xFF1E88E5);
    if (t < 20) return const Color(0xFF43A047);
    if (t < 30) return const Color(0xFFFF8F00);
    return const Color(0xFFE53935);
  }

  String get _tempEmoji {
    final t = weather.temperature;
    if (t < 0) return '🥶';
    if (t < 10) return '🧥';
    if (t < 20) return '😊';
    if (t < 30) return '☀️';
    return '🔥';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cityLatLng = LatLng(weather.lat, weather.lon);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F4FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar Premium ──
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            backgroundColor: isDark
                ? const Color(0xFF1A1F2E)
                : const Color(0xFF1565C0),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.15),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0xFF1565C0),
                            const Color(0xFF0D1117),
                          ]
                        : [
                            const Color(0xFF0D47A1),
                            const Color(0xFF42A5F5),
                          ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Cercles décoratifs
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),

                    // Contenu
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Température grande
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${weather.temperature.round()}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 72,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        '°C',
                                        style: GoogleFonts.poppins(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Ville + pays
                                Text(
                                  '${weather.cityName}, ${weather.country}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${weather.description[0].toUpperCase()}${weather.description.substring(1)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Icône météo + emoji
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(_tempEmoji,
                                  style: const TextStyle(fontSize: 28)),
                              Image.network(
                                weather.iconUrl,
                                width: 90,
                                height: 90,
                                errorBuilder: (_, __, ___) => const Text(
                                    '🌤',
                                    style: TextStyle(fontSize: 70)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Contenu principal ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résumé rapide
                  _buildQuickStats(context, isDark),

                  const SizedBox(height: 20),

                  // Grille d'infos détaillées
                  _buildSectionTitle(context, '📊', 'Détails météo'),
                  const SizedBox(height: 12),
                  _buildInfoGrid(context, isDark),

                  const SizedBox(height: 24),

                  // Carte
                  _buildSectionTitle(context, '📍', 'Localisation'),
                  const SizedBox(height: 12),
                  _buildMap(context, cityLatLng, isDark),

                  const SizedBox(height: 12),

                  // Coordonnées GPS
                  _buildCoordinates(context, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String emoji, String title) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _tempColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _tempColor.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(context, '🌡', 'Ressenti',
              weather.feelsLikeFormatted),
          _buildDivider(),
          _buildStatItem(
              context, '💧', 'Humidité', '${weather.humidity}%'),
          _buildDivider(),
          _buildStatItem(context, '💨', 'Vent',
              '${weather.windSpeed.round()} m/s'),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String emoji, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _tempColor,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey.withOpacity(0.15),
    );
  }

  Widget _buildInfoGrid(BuildContext context, bool isDark) {
    final items = [
      {
        'emoji': '🌡',
        'label': 'Ressenti',
        'value': weather.feelsLikeFormatted,
        'sub': 'Température ressentie'
      },
      {
        'emoji': '💧',
        'label': 'Humidité',
        'value': '${weather.humidity}%',
        'sub': 'Taux d\'humidité'
      },
      {
        'emoji': '💨',
        'label': 'Vent',
        'value': '${weather.windSpeed.round()} m/s',
        'sub': 'Vitesse du vent'
      },
      {
        'emoji': '🌍',
        'label': 'Pays',
        'value': weather.country,
        'sub': weather.cityName
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _tempColor.withOpacity(0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['emoji']!,
                      style: const TextStyle(fontSize: 22)),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _tempColor.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['value']!,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _tempColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item['label']!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMap(
      BuildContext context, LatLng cityLatLng, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 280,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: cityLatLng,
              initialZoom: 11,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.weather_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: cityLatLng,
                    width: 90,
                    height: 70,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _tempColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: _tempColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            weather.tempFormatted,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.location_on_rounded,
                          color: _tempColor,
                          size: 32,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoordinates(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _tempColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _tempColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.my_location_rounded,
                size: 18, color: _tempColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coordonnées GPS',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Lat: ${weather.lat.toStringAsFixed(4)}  •  Lon: ${weather.lon.toStringAsFixed(4)}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

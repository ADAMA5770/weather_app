// lib/screens/loading_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import 'results_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();

  double _progress = 0.0;
  int _messageIndex = 0;
  bool _isComplete = false;
  bool _hasError = false;
  String _errorMessage = '';
  List<WeatherModel> _weatherData = [];
  int _currentCity = 0;

  final List<String> _messages = [
    '🌍 Nous téléchargeons les données...',
    '⚡ C\'est presque fini...',
    '⏳ Plus que quelques secondes...',
    '🔄 Analyse des données météo...',
    '✨ Finalisation en cours...',
  ];

  Timer? _messageTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _messageTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (mounted && !_isComplete) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _messages.length;
        });
      }
    });

    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _progress = 0.0;
      _hasError = false;
      _isComplete = false;
      _weatherData = [];
      _currentCity = 0;
    });

    try {
      List<WeatherModel> results = [];
      final cities = WeatherService.cities;
      for (int i = 0; i < cities.length; i++) {
        setState(() => _currentCity = i);
        final weather = await _weatherService.getWeatherForCity(cities[i]);
        results.add(weather);
        setState(() => _progress = (i + 1) / cities.length);
        await Future.delayed(const Duration(milliseconds: 600));
      }
      _weatherData = results;
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() => _isComplete = true);
        _messageTimer?.cancel();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
        _messageTimer?.cancel();
      }
    }
  }

  void _goToResults() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ResultsScreen(weatherData: _weatherData),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D1117) : const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: Text('Chargement',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: _hasError
              ? _buildErrorWidget()
              : _isComplete
                  ? _buildCompleteWidget()
                  : _buildLoadingWidget(isDark),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Text(
          'Récupération météo',
          style: GoogleFonts.poppins(
              fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '📍 ${WeatherService.cities[_currentCity]}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Jauge avec halo lumineux
        ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.25),
                  blurRadius: 50,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: CircularPercentIndicator(
              radius: 90,
              lineWidth: 11,
              percent: _progress,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(_progress * 100).round()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    '${(_progress * 5).round()} / 5',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              progressColor: Theme.of(context).colorScheme.primary,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.08)
                  : const Color(0xFF1565C0).withOpacity(0.1),
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
              animationDuration: 500,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Message animé
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(0, 0.15), end: Offset.zero)
                  .animate(anim),
              child: child,
            ),
          ),
          child: Container(
            key: ValueKey(_messageIndex),
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Text(
              _messages[_messageIndex],
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Liste des villes dans une carte
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: WeatherService.cities.asMap().entries.map((entry) {
              final idx = entry.key;
              final city = entry.value;
              final done = idx < (_progress * 5).round();
              final loading = idx == _currentCity && !done;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        done
                            ? Icons.check_circle_rounded
                            : loading
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                        key: ValueKey('$idx-$done-$loading'),
                        color: done
                            ? Colors.green
                            : loading
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.withOpacity(0.4),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        city,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: done || loading
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: done
                              ? Colors.green
                              : loading
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                        ),
                      ),
                    ),
                    if (done)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('✓ OK',
                            style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.w600)),
                      )
                    else if (loading)
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCompleteWidget() {
    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
          ),
          child: const Center(
              child: Text('💥', style: TextStyle(fontSize: 52))),
        ),
        const SizedBox(height: 20),
        Text('C\'est prêt !',
            style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.green)),
        const SizedBox(height: 6),
        Text('${_weatherData.length} villes chargées avec succès 🌍',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _goToResults,
            icon: const Icon(Icons.bar_chart_rounded),
            label: Text('Voir les résultats',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _loadWeatherData,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('Recommencer 🔁',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              side: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Center(
              child: Text('❌', style: TextStyle(fontSize: 48))),
        ),
        const SizedBox(height: 20),
        Text('Oups ! Une erreur est survenue',
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.red.withOpacity(0.25)),
          ),
          child: Text(_errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.red)),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _loadWeatherData,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('Réessayer 🔄',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}

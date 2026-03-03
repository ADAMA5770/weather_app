# 🌤 WeatherPulse - Application Flutter Météo

## 👥 Membres du groupe

| Nom | Prénom | Matricule |
|-----|--------|-----------|
| NOM 1 | Prénom 1 | XXXX |
| NOM 2 | Prénom 2 | XXXX |
| NOM 3 | Prénom 3 | XXXX |

## 📱 Présentation

Application Flutter développée dans le cadre de l'examen de Développement Mobile - L3GL ISI 2026.

### Fonctionnalités
- ✅ Écran d'accueil animé
- ✅ Jauge de progression animée
- ✅ Appels API OpenWeather pour 5 villes : Dakar, Paris, New York, Tokyo, London
- ✅ Messages d'attente dynamiques en boucle
- ✅ Tableau interactif des données météo
- ✅ Détail d'une ville avec carte interactive (OpenStreetMap)
- ✅ Gestion des erreurs avec bouton réessayer
- ✅ Mode sombre et clair
- ✅ Navigation fluide

## 🛠 Technologies utilisées

- **Flutter** 3.x
- **Dio** - Appels HTTP
- **Provider** - Gestion d'état
- **flutter_map + latlong2** - Carte interactive
- **percent_indicator** - Jauge de progression
- **google_fonts** - Typographie

## ⚙️ Configuration

### Clé API OpenWeather
1. Crée un compte gratuit sur [openweathermap.org](https://openweathermap.org/api)
2. Génère une clé API
3. Dans `lib/services/weather_service.dart`, remplace `VOTRE_CLE_API_ICI` par ta clé

### Installation
```bash
flutter pub get
flutter run
```

## 📁 Structure du projet
```
lib/
├── main.dart                    # Point d'entrée
├── models/
│   └── weather_model.dart       # Modèle de données météo
├── services/
│   └── weather_service.dart     # Service API (Dio)
├── providers/
│   └── theme_provider.dart      # Gestion thème clair/sombre
└── screens/
    ├── home_screen.dart          # Écran d'accueil
    ├── loading_screen.dart       # Jauge + chargement API
    ├── results_screen.dart       # Tableau des résultats
    └── city_detail_screen.dart   # Détail ville + carte
```

---
*Projet L3GL ISI - Examen Développement Mobile 2026*

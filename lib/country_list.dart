import 'dart:convert';
import 'package:http/http.dart' as http;

// Curated names to ensure these appear in the list.
const List<String> curatedCountryNames = [
  'Armenia',
  'Samoa',
  'Jersey',
  'Japan',
  'Bolivia',
  'Chile',
  'United States',
  'Saint Vincent and the Grenadines',
  'Bermuda',
  'Seychelles',
  'British Indian Ocean Territory',
  'Guatemala',
  'Ecuador',
  'Martinique',
  'Tajikistan',
];

String _normalizeCountryName(String name) {
  // Remove parenthetical parts like "Bolivia (Plurinational State of)"
  String n = name.replaceAll(RegExp(r"\s*\([^)]*\)"), '').trim();
  // Common alias fixes
  const aliases = {
    'United States of America': 'United States',
  };
  return aliases[n] ?? n;
}

Future<List<String>> fetchCountries() async {
  final response = await http.get(
    Uri.parse('https://restcountries.com/v3.1/all'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> countriesJson = json.decode(response.body) as List<dynamic>;
    final Set<String> unique = {};
    for (final country in countriesJson) {
      try {
        final map = country as Map<String, dynamic>;
        final name = (map['name'] as Map<String, dynamic>)['common'] as String;
        unique.add(_normalizeCountryName(name));
      } catch (_) {
        // skip invalid
      }
    }
    // Ensure curated items are included
    unique.addAll(curatedCountryNames);

    final List<String> countryList = unique.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return countryList;
  } else {
    throw Exception('Failed to load countries');
  }
}

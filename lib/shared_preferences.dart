import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// Utility wrapper for saving/loading app data in SharedPreferences.
class HabitPrefs {
  static const String _selectedKey = 'selectedHabitsMap';
  static const String _completedKey = 'completedHabitsMap';
  static const String _actionsKey = 'userActions';
  static const String _notificationsKey = 'notifications';

  // Profile keys (kept individual for compatibility with existing code)
  static const String _nameKey = 'name';
  static const String _emailKey = 'email';
  static const String _usernameKey = 'username';
  static const String _passwordKey = 'password';
  static const String _ageKey = 'age';
  static const String _countryKey = 'country';
  static const String _habitsKey = 'habits';
  static const String _registeredKey = 'registered';

  static Future<Map<String, String>> loadSelected() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_selectedKey);
    if (raw == null || raw.isEmpty) return <String, String>{};
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      return decoded.map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      return <String, String>{};
    }
  }

  static Future<Map<String, String>> loadCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_completedKey);
    if (raw == null || raw.isEmpty) return <String, String>{};
    try {
      final Map<String, dynamic> decoded = jsonDecode(raw);
      return decoded.map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      return <String, String>{};
    }
  }

  static Future<void> saveMaps({
    required Map<String, String> selected,
    required Map<String, String> completed,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedKey, jsonEncode(selected));
    await prefs.setString(_completedKey, jsonEncode(completed));
  }

  // User Profile
  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, profile.name);
    await prefs.setString(_emailKey, profile.email);
    await prefs.setString(_usernameKey, profile.username);
    await prefs.setString(_passwordKey, profile.password);
    await prefs.setInt(_ageKey, profile.age);
    await prefs.setString(_countryKey, profile.country);
    await prefs.setStringList(_habitsKey, profile.habits);
    await prefs.setBool(_registeredKey, true);
  }

  static Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_usernameKey);
    final name = prefs.getString(_nameKey);
    if (username == null && name == null) return null;
    return UserProfile(
      name: name ?? '',
      email: prefs.getString(_emailKey) ?? '',
      username: username ?? '',
      password: prefs.getString(_passwordKey) ?? '',
      age: prefs.getInt(_ageKey) ?? 0,
      country: prefs.getString(_countryKey) ?? '',
      habits: prefs.getStringList(_habitsKey) ?? <String>[],
    );
  }

  // Actions
  static Future<void> saveUserAction(String action) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> actions = prefs.getStringList(_actionsKey) ?? <String>[];
    actions.add(action);
    await prefs.setStringList(_actionsKey, actions);
  }

  static Future<List<String>> getUserActions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_actionsKey) ?? <String>[];
  }

  static Future<void> clearUserActions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_actionsKey);
  }

  // Notifications
  static Future<void> addNotification(String message) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> notifs = prefs.getStringList(_notificationsKey) ?? <String>[];
    notifs.add(message);
    await prefs.setStringList(_notificationsKey, notifs);
  }

  static Future<List<String>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_notificationsKey) ?? <String>[];
  }

  static Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationsKey);
  }
}

class UserProfile {
  final String name;
  final String email;
  final String username;
  final String password;
  final int age;
  final String country;
  final List<String> habits;

  UserProfile({
    required this.name,
    required this.email,
    required this.username,
    required this.password,
    required this.age,
    required this.country,
    required this.habits,
  });
}

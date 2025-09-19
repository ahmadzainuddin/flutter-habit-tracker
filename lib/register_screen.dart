import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'habit_tracker_screen.dart';
import 'shared_preferences.dart' as habit_prefs;
import 'country_list.dart';
//flutter devices -v
//flutter run -d 26337AB5-D0B5-481B-B21E-FC7791056A3E

//open -a Simulator
//xcrun simctl boot "My iPhone (iOS 26)" 2>/dev/null || true
//flutter run -d "My iPhone (iOS 26)"

void _showToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  double _age = 25; // Default age set to 25
  String _country = 'United States';
  List<String> _countries = [];
  List<String> selectedHabits = [];
  List<String> availableHabits = [
    'Wake Up Early',
    'Workout',
    'Drink Water',
    'Meditate',
    'Read a Book',
    'Practice Gratitude',
    'Sleep 8 Hours',
    'Eat Healthy',
    'Journal',
    'Walk 10,000 Steps',
  ];

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  Future<void> _fetchCountries() async {
    try {
      final list = await fetchCountries();
      list.sort();
      setState(() {
        _countries = list;
        _country = _countries.isNotEmpty ? _countries.first : 'United States';
      });
    } catch (e) {
      // Fallback list if network fails
      final fallback = [
        'United States',
        'Canada',
        'United Kingdom',
        'Australia',
        'India',
        'Germany',
        'France',
        'Japan',
        'China',
        'Brazil',
        'South Africa',
        'Malaysia',
      ]..sort();
      setState(() {
        _countries = fallback;
        _country = _countries.first;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your name');
      return;
    }
    if (username.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a username');
      return;
    }
    if (email.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter your email');
      return;
    }
    if (!_isValidEmail(email)) {
      Fluttertoast.showToast(msg: 'Please enter a valid email');
      return;
    }
    if (password.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter a password');
      return;
    }
    if (password.length < 6) {
      Fluttertoast.showToast(msg: 'Password must be at least 6 characters');
      return;
    }
    if (confirmPassword != password) {
      Fluttertoast.showToast(msg: 'Passwords do not match');
      return;
    }
    if (selectedHabits.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select at least one habit');
      return;
    }

    try {
      await habit_prefs.HabitPrefs.saveUserProfile(
        habit_prefs.UserProfile(
          name: name,
          email: email,
          username: username,
          password: password,
          age: _age.round(),
          country: _country,
          habits: List<String>.from(selectedHabits),
        ),
      );

      Fluttertoast.showToast(msg: 'Registration successful');

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to register: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text(
          'Register',
          style: TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(_nameController, 'Name', Icons.person),
                const SizedBox(height: 10),
                _buildInputField(_emailController, 'Email', Icons.email),
                const SizedBox(height: 10),
                _buildInputField(
                  _usernameController,
                  'Username',
                  Icons.alternate_email,
                ),
                const SizedBox(height: 10),
                // Password
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
                      hintText: 'Password',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Confirm Password
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.blue.shade700,
                      ),
                      hintText: 'Retype Password',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Age: ${_age.round()}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Slider(
                  value: _age,
                  min: 21,
                  max: 100,
                  divisions: 79,
                  activeColor: Colors.blue.shade600,
                  inactiveColor: Colors.blue.shade300,
                  onChanged: (double value) {
                    setState(() {
                      _age = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                _buildCountryDropdown(),
                const SizedBox(height: 10),
                const Text(
                  'Select Your Habits',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: availableHabits.map((habit) {
                    final isSelected = selectedHabits.contains(habit);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedHabits.remove(habit);
                          } else {
                            selectedHabits.add(habit);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.shade600
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue.shade700),
                        ),
                        child: Text(
                          habit,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    final hasData = _countries.isNotEmpty;
    return Container
      (
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: hasData
          ? DropdownButton<String>(
              value: _countries.contains(_country) ? _country : null,
              hint: const Text('Select Country'),
              icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
              isExpanded: true,
              menuMaxHeight: 480,
              dropdownColor: Colors.white,
              underline: const SizedBox(),
              items: _countries.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) {
                if (newValue == null) return;
                setState(() {
                  _country = newValue;
                });
              },
            )
          : const Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Row(
                children: [
                  SizedBox(width: 8),
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Loading countries...'),
                ],
              ),
            ),
    );
  }
}

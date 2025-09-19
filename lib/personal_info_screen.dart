import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'country_list.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  double _age = 25;
  String _country = 'United States';
  List<String> _countries = [];

  @override
  void initState() {
    super.initState();
    _loadCountries().then((_) {
      _loadUserData();
    });
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await fetchCountries();
      countries.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      setState(() {
        _countries = countries;
      });
    } catch (e) {
      // Fallback minimal list if API fails
      final fallback = [
        'United States',
        'Canada',
        'United Kingdom',
        'Australia',
        'Malaysia',
      ]..sort();
      setState(() {
        _countries = fallback;
      });
      _showToast('Error fetching countries');
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _usernameController.text = prefs.getString('username') ?? '';
      _age = (prefs.getInt('age') ?? 25).toDouble();
      _country = prefs.getString('country') ?? 'United States';
      if (_countries.isNotEmpty && !_countries.contains(_country)) {
        _country = _countries.first;
      }
    });
  }

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('username', _usernameController.text);
    await prefs.setInt('age', _age.round());
    await prefs.setString('country', _country);

    Fluttertoast.showToast(
      msg: "Profile updated successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    // Pass back the updated name
    Navigator.pop(context, _nameController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text('Personal Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 42),
            _buildTextField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _usernameController,
              label: 'Username',
              icon: Icons.alternate_email,
            ),
            const SizedBox(height: 16),
            Text(
              'Age: ${_age.round()}',
              style: TextStyle(color: Colors.blue.shade700, fontSize: 18),
            ),
            Slider(
              value: _age,
              min: 21,
              max: 100,
              divisions: 79,
              activeColor: Colors.blue.shade600,
              inactiveColor: Colors.blue.shade300,
              onChanged: (value) {
                setState(() {
                  _age = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade700),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: _countries.isEmpty
                  ? const Padding(
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
                    )
                  : DropdownButton<String>(
                      value: _countries.contains(_country) ? _country : null,
                      hint: const Text('Select Country'),
                      isExpanded: true,
                      menuMaxHeight: 480,
                      dropdownColor: Colors.white,
                      underline: const SizedBox(),
                      items: _countries
                          .map((String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        if (newValue == null) return;
                        setState(() {
                          _country = newValue;
                        });
                      },
                    ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 16,
                ),
                elevation: 5,
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade700),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }

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
}

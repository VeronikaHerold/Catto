import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'start_screen.dart';
import 'impressum_screen.dart';
import 'datenschutz_screen.dart';

class ProfileConfigurationScreen extends StatefulWidget {
  @override
  _ProfileConfigurationScreenState createState() =>
      _ProfileConfigurationScreenState();
}

class _ProfileConfigurationScreenState
    extends State<ProfileConfigurationScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  String currentEmail = "";
  String currentUsername = "";
  String currentBirthDate = "";

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    birthDateController.text = currentBirthDate;
  }

  void _loadCurrentUser() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentEmail = user.email ?? "";
        currentUsername = user.displayName ?? "Anonym";
        // currentBirthDate = getBirthDateFromSomewhere(); // Fetch user's birthdate
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil konfigurieren'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildProfileField('Aktuelle E-Mail-Adresse:', currentEmail),
          SizedBox(height: 20),
          _buildTextField(usernameController, 'Neuer Benutzername'),
          SizedBox(height: 12),
          _buildTextField(passwordController, 'Neues Passwort', isObscureText: true),
          SizedBox(height: 20),
          _buildProfileField('Aktueller Benutzername:', currentUsername),
          SizedBox(height: 20),
          _buildTextField(birthDateController, 'Neues Geburtsdatum'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updateProfile,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text('Profil aktualisieren', style: TextStyle(fontSize: 16)),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLink('Impressum', ImpressumScreen()),
              SizedBox(width: 20),
              _buildLink('Datenschutz', DatenschutzScreen()),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool isObscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: isObscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildLink(String label, Widget screen) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Text(
        label,
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
          fontSize: 16.0,
        ),
      ),
    );
  }

  void _updateProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null) {
        if (usernameController.text.isNotEmpty) {
          await user.updateDisplayName(usernameController.text);
          setState(() {
            currentUsername = usernameController.text;
          });
        }

        if (passwordController.text.isNotEmpty) {
          await user.updatePassword(passwordController.text);
        }

        setState(() {
          currentBirthDate = birthDateController.text;
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Profil aktualisiert'),
              content: Text('Ihr Profil wurde erfolgreich aktualisiert!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Fehler beim Aktualisieren'),
            content: Text(e.message ?? 'Ein Fehler ist aufgetreten.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => StartScreen()),
          (route) => false,
    );
  }
}

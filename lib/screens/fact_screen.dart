import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:translator/translator.dart';

class FactScreen extends StatefulWidget {
  @override
  _FactScreenState createState() => _FactScreenState();
}

class _FactScreenState extends State<FactScreen> {
  String? _originalCatFact;
  String? _currentCatFact;
  final translator = GoogleTranslator();
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _fetchRandomCatFact();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _fetchRandomCatFact() async {
    final response = await http.get(Uri.parse('https://catfact.ninja/fact?max_length=140'));

    if (response.statusCode == 200 && _isMounted) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        _originalCatFact = jsonResponse['fact'];
        _currentCatFact = _originalCatFact;
      });
    } else {
      throw Exception('Failed to load cat fact');
    }
  }

  Future<void> _translateText(bool toGerman) async {
    Translation translation;
    if (toGerman) {
      translation = await translator.translate(_originalCatFact ?? '', to: 'de');
    } else {
      translation = await translator.translate(_currentCatFact ?? '', to: 'en');
    }

    if (_isMounted) {
      setState(() {
        _currentCatFact = translation.text;
      });
    }
  }

  void _showCatFactDialog() {
    if (!_isMounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Zufällige Katzenweisheit des Tages'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_currentCatFact ?? _originalCatFact ?? 'Loading...'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _translateText(true); // Deutsch
                Navigator.of(context).pop();
                _showCatFactDialog();
              },
              child: Text('Deutsch'),
            ),
            TextButton(
              onPressed: () async {
                await _translateText(false); // Englisch
                Navigator.of(context).pop();
                _showCatFactDialog();
              },
              child: Text('Original'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weisheit des Tages'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _originalCatFact != null ? _showCatFactDialog : null,
          child: Text('Katzenweisheit anzeigen'),
        ),
      ),
      backgroundColor: Color(0xA4A0A0FF), // Hintergrundfarbe hinzugefügt
    );
  }
}

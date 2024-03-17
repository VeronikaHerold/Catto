import 'package:flutter/material.dart';

class ImpressumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Impressum'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Angaben gem. § 5 TMG:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Vorname, Name',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Adresse',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'PLZ',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Kontaktaufnahme:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Telefon:',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Fax:',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'E-Mail:',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

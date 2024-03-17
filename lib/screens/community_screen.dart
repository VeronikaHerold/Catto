import 'package:flutter/material.dart';
import 'chat_screen.dart';

class CommunityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kategorien auswählen'),
      ),
      body: GridView.count(
        crossAxisCount: 2, // Zwei Kategorien nebeneinander
        childAspectRatio: 1.2, // Verhältnis Breite zu Höhe
        children: [
          _buildCategoryItem(context, "Katzenpflege"),
          _buildCategoryItem(context, "Wissenswertes"),
          _buildCategoryItem(context, "Verhalten und Erziehung"),
          _buildCategoryItem(context, "Krankheiten und Notfallversorgung"),
          _buildCategoryItem(context, "Forum"),
          _buildCategoryItem(context, "Community")
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String category) {
    return Card(
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          // Öffne die Chat-Seite beim Antippen der Kategorie
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(userName: category),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              category,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

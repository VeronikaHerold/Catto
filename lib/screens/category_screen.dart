import 'race_screen.dart';
import 'package:flutter/material.dart';
import 'forum_screen.dart';
import 'care_screen.dart';
import 'fact_screen.dart';
import 'profile_screen.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  Map<IconData, bool> iconHoverState = {
    Icons.pets: false,
    Icons.cleaning_services: false,
    Icons.lightbulb_outline: false,
    Icons.forum: false,
    Icons.group: false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xA4A0A0FF),
      appBar: AppBar(
        title: Text('Kategorien auswählen'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileConfigurationScreen()),
              );
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 1,
        padding: EdgeInsets.all(16.0),
        childAspectRatio: 3.0, // Anpassen des Seitenverhältnisses
        mainAxisSpacing: 20.0, // Vertikaler Abstand zwischen den Karten
        crossAxisSpacing: 20.0, // Horizontaler Abstand zwischen den Karten
        children: [
          _buildCategoryItem(context, "Katzenrassen", RaceScreen(), Icons.pets, Colors.blue),
          _buildCategoryItem(context, "Katzenpflege", CareScreen(), Icons.cleaning_services, Colors.green),
          _buildCategoryItem(context, "Wissenswertes", FactScreen(),Icons.lightbulb_outline, Colors.orange),
          _buildCategoryItem(context, "Forum", ForumScreen(), Icons.forum, Colors.purple),
        ],
      ),
    );
  }

  void _changeColor(BuildContext context, IconData icon, Color color, bool isHovering) {
    setState(() {
      iconHoverState[icon] = isHovering;
    });
  }


  Widget _buildCategoryItem(BuildContext context, String category, Widget? route, IconData icon, Color color) {
    bool isHovering = iconHoverState[icon] ?? false;

    return GestureDetector(
      onTap: () {
        if (route != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => route),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Diese Kategorie ist noch in Arbeit')),
          );
        }
      },
      child: MouseRegion(
        onEnter: (_) {
          _changeColor(context, icon, color.withOpacity(0.8), true);
        },
        onExit: (_) {
          _changeColor(context, icon, color, false);
        },
        child: Card(
          elevation: isHovering ? 8.0 : 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          color: isHovering ? color.withOpacity(0.8) : color,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50.0,
                color: Colors.white,
              ),
              SizedBox(height: 10.0),
              Text(
                category,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }


}

import 'package:flutter/material.dart';
import 'package:Catto/model/cat_data.dart';

class RaceScreen extends StatefulWidget {
  @override
  _RaceScreenState createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  Set<String> favoriteBreeds = {};
  List<Map<String, String?>> filteredProfiles = [];

  void _toggleFavorite(String breed) {
    setState(() {
      if (favoriteBreeds.contains(breed)) {
        favoriteBreeds.remove(breed);
      } else {
        favoriteBreeds.add(breed);
      }
    });
  }

  bool _isFavorite(String breed) {
    return favoriteBreeds.contains(breed);
  }

  void _filterProfiles(String query) {
    setState(() {
      filteredProfiles = CatData.catProfiles.where((profile) {
        return profile['breed']!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    filteredProfiles = List.from(CatData.catProfiles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Katzenrassen'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              _showFavorites(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      _filterProfiles(value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Nach Rasse suchen',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProfiles.length,
              itemBuilder: (context, index) {
                final profile = filteredProfiles[index];
                return _buildProfileItem(profile);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFavorites(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: favoriteBreeds.map((breed) {
            return ListTile(
              title: Text(breed),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BreedDetailScreen(breed),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildProfileItem(Map<String, String?> profile) {
    final breed = profile['breed']!;
    final description = profile['description'] ?? 'Keine Beschreibung verfügbar';
    final isFavorite = _isFavorite(breed);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        title: Text(
          breed,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: IconButton(
          icon: isFavorite ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
          onPressed: () {
            _toggleFavorite(breed);
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BreedDetailScreen(breed),
            ),
          );
        },
      ),
    );
  }
}

class BreedDetailScreen extends StatelessWidget {
  final String breed;

  BreedDetailScreen(this.breed);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(breed),
      ),
      body: Center(
        child: Text('Details zur Rasse $breed'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RaceScreen(),
  ));
}

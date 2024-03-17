import 'package:flutter/material.dart';

class CareScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Katzenpflege'),
      ),
      body: GridView.count(
        crossAxisCount: 1,
        childAspectRatio: 3,
        children: [
          _buildCategoryItem(context, "Das erste Mal eine Katze halten", [
            "Vorbereitung des Zuhauses für eine neue Katze",
            "Beschaffung der notwendigen Ausrüstung",
            "Einführung in das neue Zuhause",
            "Wichtige Dinge, die man beachten sollte"
          ]),
          _buildCategoryItem(context, "Wissenswerte Fakten über Katzen", [
            "Katzenernährung: Bedürfnisse und Empfehlungen",
            "Katzenverhalten: Was sagt das Verhalten der Katze aus?",
            "Katzengesundheit: Anzeichen für eine gesunde Katze",
            "Katzenrassen: Unterschiede und Besonderheiten"
          ]),
          _buildCategoryItem(context, "Verhalten und Erziehung", [
            "Katzentraining: Grundlegende Befehle und Tricks",
            "Umgang mit unerwünschtem Verhalten",
            "Sozialisierung von Katzen",
            "Tipps für eine harmonische Beziehung mit deiner Katze"
          ]),
          _buildCategoryItem(context, "Krankheiten und Notfallversorgung", [
            "Häufige Katzenkrankheiten: Symptome und Behandlungen",
            "Tierarztbesuche: Regelmäßige Untersuchungen und Impfungen",
            "Notfallvorsorge: Erste Hilfe bei Katzen",
            "Katzenversicherung: Sinnvoll oder nicht?"
          ]),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String category, List<String> subcategories) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        margin: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: GestureDetector(
          onTap: () {
            if (subcategories.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubCategoryScreen(subcategories),
                ),
              );
            }
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFA78BFA), Color(0xFF9575CD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
      ),
    );
  }
}

class SubCategoryScreen extends StatelessWidget {
  final List<String> subcategories;

  SubCategoryScreen(this.subcategories);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Katzenpflege'),
      ),
      body: ListView.builder(
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(subcategories[index]),
            onTap: () {
              _showInformationDialog(context, subcategories[index]);
            },
          );
        },
      ),
    );
  }

  void _showInformationDialog(BuildContext context, String subcategory) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Wichtige Informationen zu $subcategory"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInformation(subcategory),
              ],
            ),
          ),
          actions: [
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

  Widget _buildInformation(String subcategory) {
    switch (subcategory) {
      case "Vorbereitung des Zuhauses für eine neue Katze":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bevor du deine Katze nach Hause bringst, solltest du Folgendes berücksichtigen:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("1. Reinige das Haus gründlich, insbesondere Bereiche, die für die Katze zugänglich sein werden."),
            Text("2. Besorge eine Katzentoilette und wähle die richtige Art von Streu."),
            Text("3. Sichere Fenster und Balkone, um Unfälle zu vermeiden."),
            Text("4. Bereite einen ruhigen Rückzugsort vor, den die Katze erkunden kann."),
          ],
        );
      case "Beschaffung der notwendigen Ausrüstung":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Wichtige Ausrüstung, die du für deine Katze benötigst:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("1. Katzentoilette: Wähle eine, die groß genug ist und leicht zugänglich ist."),
            Text("2. Kratzbaum oder Kratzbrett: Zum Schärfen der Krallen und als Spielmöglichkeit."),
            Text("3. Futternäpfe und Wasserbehälter: Stelle sicher, dass sie leicht zu reinigen sind."),
            Text("4. Spielzeug: Katzen benötigen Spielzeug zur geistigen und körperlichen Stimulation."),
          ],
        );
      case "Tierarztbesuche: Regelmäßige Untersuchungen und Impfungen":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Regelmäßige Tierarztbesuche und Impfungen sind wichtig für die Gesundheit deiner Katze:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("1. Jährliche Untersuchungen: Dein Tierarzt kann Gesundheitsprobleme frühzeitig erkennen."),
            Text("2. Impfungen: Katzen benötigen Impfungen gegen bestimmte Krankheiten wie Katzenseuche und Katzenschnupfen."),
            Text("3. Entwurmung: Dein Tierarzt kann dir raten, deine Katze regelmäßig zu entwurmen, um Parasitenbefall zu verhindern."),
            Text("4. Floh- und Zeckenschutz: Schütze deine Katze vor Parasiten, indem du entsprechende Präventivmaßnahmen ergreifst."),
          ],
        );
      case "Notfallvorsorge: Erste Hilfe bei Katzen":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Wichtige Notfallmaßnahmen, die du kennen solltest:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("1. Kenne die Anzeichen von Notfällen wie Atemnot oder Vergiftungen."),
            Text("2. Halte eine Notfallausrüstung bereit, die Verbandsmaterial, sterile Spritzen und Desinfektionsmittel umfasst."),
            Text("3. Wisse, wie man eine Katze bei Atemnot oder Herzstillstand wiederbelebt."),
            Text("4. Informiere dich über Notfalldienste und Tierkliniken in deiner Nähe."),
          ],
        );
      case "Katzenversicherung: Sinnvoll oder nicht?":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Eine Katzenversicherung kann sinnvoll sein, um unerwartete Kosten abzudecken:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("1. Unterschiedliche Versicherungspakete bieten unterschiedliche Leistungen, darunter Tierarztkosten, Operationen und Medikamente."),
            Text("2. Überlege, ob du die monatlichen Prämien gegen mögliche Tierarztkosten abwägen möchtest."),
            Text("3. Beachte, dass bestimmte Rassen möglicherweise anfälliger für bestimmte Krankheiten sind, was die Versicherungskosten beeinflussen kann."),
          ],
        );
      default:
        return Text("Keine Informationen verfügbar.");
    }
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Katzenpflege',
    theme: ThemeData(
      primaryColor: Color(0xFF9575CD),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xFF7E57C2)),
      fontFamily: 'Roboto',
    ),
    home: CareScreen(),
  ));
}

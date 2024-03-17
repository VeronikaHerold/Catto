import 'package:Catto/screens/loading_screen.dart';
import 'package:flutter/material.dart';
import 'screens/start_screen.dart';
import 'screens/category_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyAyWGPGxDdmm5gwOMXhXAnsBPD-4BjslKA',
      authDomain: 'catto-4d4de.firebaseapp.com',
      projectId: 'catto-4d4de', appId: '', messagingSenderId: '',
      storageBucket: "catto-4d4de.appspot.com",
    ),
  );
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoadingScreen(),
      routes: {
        '/main': (context) => StartScreen(),
        '/secondary': (context) => CategoryScreen(),
      },
    );
  }
}


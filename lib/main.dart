import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'models/3d_model_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ModelProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '3D Model Displayer',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomeScreen(),
      ),
    );
  }
}
/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:three_d_model_viewer/models/3d_model_provider.dart';
import 'screens/home_screen.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ModelState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Model Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

*/

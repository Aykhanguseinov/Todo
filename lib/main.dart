import 'package:flutter/material.dart'; 
import 'todolistpage.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 

void main() async { 
  WidgetsFlutterBinding.ensureInitialized(); 
  await SharedPreferences.getInstance(); 
  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget { 
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) { 
    return MaterialApp( 
      title: 'Todo', 
      theme: ThemeData( 
        brightness: Brightness.dark, 
        primaryColor: Colors.orange, 
        scaffoldBackgroundColor: Colors.black, 
        appBarTheme: const AppBarTheme( 
          backgroundColor: Colors.orange, 
          titleTextStyle: TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold), 
        ),
        elevatedButtonTheme: ElevatedButtonThemeData( 
          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.orange), 
            textStyle: MaterialStateProperty.all( 
            const TextStyle(color: Colors.black),
            ),
          ),
        ),
        textTheme: const TextTheme( 
          bodyLarge: TextStyle(color: Colors.white), 
          headlineLarge: TextStyle(color: Colors.white), 
        ),
      ),
      home: const TodoListPage(), 
    );
  }
}

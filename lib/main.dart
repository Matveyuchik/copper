import 'package:flutter/material.dart';
import 'auth_screen.dart';

void main() {
  runApp(const Copper());
}

class Copper extends StatelessWidget {
  const Copper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Copper Messenger',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthScreen()
      },
      onGenerateRoute: (settings) {  
        return null;
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Finance Tracker',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366f1),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.interTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFf3f4f6),
             cardTheme: CardThemeData(
            elevation: 0, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.white,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366f1),
            brightness: Brightness.dark,
            surface: const Color(0xFF0f172a), 
          ),
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          scaffoldBackgroundColor: const Color(0xFF0f172a),
             cardTheme: CardThemeData( // Reverting to CardTheme if CardThemeData is not found, but error says CardThemeData. 
             // Actually, the error said "The argument type 'CardTheme' can't be assigned to the parameter type 'CardThemeData?'".
             // This means I MUST use CardThemeData.
            elevation: 0, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: const Color(0xFF1e293b),
          ),
        ),
        themeMode: ThemeMode.system, // or User preference
        home: const HomeScreen(),
      ),
    );
  }
}

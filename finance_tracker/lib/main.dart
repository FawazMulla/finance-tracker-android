import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:home_widget/home_widget.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';
import 'services/widget_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize widget service
  final widgetService = WidgetService();
  await widgetService.initialize();
  await widgetService.registerBackgroundCallback();
  
  // Listen for widget interactions
  HomeWidget.widgetClicked.listen((uri) {
    if (uri != null && uri.host == 'addtransaction') {
      // This will be handled in HomeScreen
    }
  });
  
  runApp(const MyApp());
}

@pragma('vm:entry-point')
void backgroundCallback(Uri? uri) {
  WidgetService.backgroundCallback(uri);
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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366f1),
            brightness: Brightness.light,
            primary: const Color(0xFF6366f1),
          ),
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          cardTheme: const CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            color: Color(0xFFf8fafc),
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366f1),
            brightness: Brightness.dark,
            primary: const Color(0xFF6366f1),
            surface: const Color(0xFF1e293b),
            onSurface: Colors.white,
          ),
          textTheme: ThemeData.dark().textTheme.copyWith(
            bodyLarge: const TextStyle(color: Color(0xFFf8fafc)),
            bodyMedium: const TextStyle(color: Color(0xFFcbd5e1)),
          ),
          scaffoldBackgroundColor: const Color(0xFF0f172a),
          cardTheme: const CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            color: Color(0xFF1e293b),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0f172a),
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        themeMode: ThemeMode.dark,
        home: const HomeScreen(),
      ),
    );
  }
}

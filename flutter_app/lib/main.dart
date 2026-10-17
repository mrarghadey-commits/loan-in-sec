import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(const LoanInSecApp());
}

class LoanInSecApp extends StatelessWidget {
  const LoanInSecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loan in Sec Underwriting',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087F75)).copyWith(
          primary: const Color(0xFF087F75), onPrimary: Colors.white,
          surface: Colors.white, onSurface: const Color(0xFF142D38),
          surfaceTint: Colors.transparent,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F8FA),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white,
          foregroundColor: Color(0xFF142D38), surfaceTintColor: Colors.transparent,
          elevation: 0, scrolledUnderElevation: 1, centerTitle: false,
          titleTextStyle: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Color(0xFF142D38))),
        cardTheme: CardThemeData(color: Colors.white, surfaceTintColor: Colors.transparent,
          elevation: 0, margin: const EdgeInsets.only(bottom: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE0E8EB)))),
        filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
        outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: Color(0xFFCBDAD9)))),
        dividerTheme: const DividerThemeData(color: Color(0xFFE4EBEE), space: 28),
        textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 14, height: 1.5),
          bodySmall: TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF607582))),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/storage_service.dart';
import 'providers/app_state.dart';
import 'providers/app_state_provider.dart';
import 'screens/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  await StorageService.init();
  
  // Initialize Spanish date formatting
  await initializeDateFormatting('es', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create global state
    final appState = AppState();

    return AppStateProvider(
      state: appState,
      child: ListenableBuilder(
        listenable: appState,
        builder: (context, child) {
          return MaterialApp(
            title: 'GastosController',
            debugShowCheckedModeBanner: false,
            
            // Localization
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', ''), // Spanish
            ],
            locale: const Locale('es', ''),

            // Theme Settings
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            
            // Light Theme Design System
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFFAF9F6), // Warm alabaster / bone
              cardColor: const Color(0xFFFFFFFF), // Pure white contrast
              primaryColor: const Color(0xFF8A7968), // Deep warm taupe
              dividerColor: const Color(0xFFECEAE4), // Soft warm grey
              hintColor: const Color(0xFF8C8A84), // Muted dark beige
              disabledColor: const Color(0xFFC0BEB9),
              
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF8A7968),
                secondary: Color(0xFF8A7968),
                surface: Color(0xFFFAF9F6),
                error: Color(0xFFB07D7D), // Muted red
              ),

              textTheme: const TextTheme(
                bodyLarge: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF1C1A17), fontSize: 14),
                bodyMedium: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF1C1A17), fontSize: 13),
                titleLarge: TextStyle(fontFamily: 'Montserrat', color: Color(0xFF1C1A17), fontWeight: FontWeight.bold),
              ),

              // Form fields styling
              inputDecorationTheme: const InputDecorationTheme(
                filled: true,
                fillColor: Color(0xFFFFFFFF),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFFECEAE4), width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFFECEAE4), width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFF8A7968), width: 1.0),
                ),
                labelStyle: TextStyle(color: Color(0xFF8C8A84), fontSize: 13, fontFamily: 'Montserrat'),
                hintStyle: TextStyle(color: Color(0xFF8C8A84), fontSize: 13, fontFamily: 'Montserrat'),
              ),
              
              datePickerTheme: DatePickerThemeData(
                headerBackgroundColor: const Color(0xFF8A7968),
                headerForegroundColor: const Color(0xFFFAF9F6),
                backgroundColor: const Color(0xFFFAF9F6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            
            // Dark Theme Design System
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF0F0F0F), // Deep graphite black
              cardColor: const Color(0xFF161616), // Darker surface contrast
              primaryColor: const Color(0xFFC5B4A1), // Warm beige-sand primary (minimal, no neon)
              dividerColor: const Color(0xFF222222), // Deep grey line
              hintColor: const Color(0xFF757575), // Charcoal grey text
              disabledColor: const Color(0xFF424242),

              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFC5B4A1),
                secondary: Color(0xFFC5B4A1),
                surface: Color(0xFF161616),
                error: Color(0xFFB07D7D), // Muted red/coral
              ),

              textTheme: const TextTheme(
                bodyLarge: TextStyle(fontFamily: 'Montserrat', color: Color(0xFFE5E5E5), fontSize: 14),
                bodyMedium: TextStyle(fontFamily: 'Montserrat', color: Color(0xFFE5E5E5), fontSize: 13),
                titleLarge: TextStyle(fontFamily: 'Montserrat', color: Color(0xFFE5E5E5), fontWeight: FontWeight.bold),
              ),

              // Form fields styling
              inputDecorationTheme: const InputDecorationTheme(
                filled: true,
                fillColor: Color(0xFF161616),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFF222222), width: 0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFF222222), width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: Color(0xFFC5B4A1), width: 1.0),
                ),
                labelStyle: TextStyle(color: Color(0xFF757575), fontSize: 13, fontFamily: 'Montserrat'),
                hintStyle: TextStyle(color: Color(0xFF757575), fontSize: 13, fontFamily: 'Montserrat'),
              ),

              datePickerTheme: DatePickerThemeData(
                headerBackgroundColor: const Color(0xFFC5B4A1),
                headerForegroundColor: const Color(0xFF0F0F0F),
                backgroundColor: const Color(0xFF161616),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'screens/admin/create_event_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/core/calendar_screen.dart';
import 'screens/core/dashboard_screen.dart';
import 'screens/core/event_detail_screen.dart';
import 'screens/core/map_screen.dart';
import 'screens/core/my_events_screen.dart';
import 'screens/settings/about_screen.dart';
import 'screens/settings/faq_screen.dart';
import 'screens/settings/feedback_screen.dart';
import 'screens/settings/notifications_screen.dart';
import 'screens/settings/preferences_screen.dart';
import 'screens/settings/privacy_screen.dart';
import 'screens/settings/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/local_storage_service.dart';
import 'utils/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final localStorageService = await LocalStorageService.create();
  final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  var firebaseEnabled = false;

  if (kIsWeb) {
    if (firebaseOptions == null) {
      debugPrint(
        'CampusBoard Firebase initialization skipped: missing web options.',
      );
    } else {
      try {
        await Firebase.initializeApp(options: firebaseOptions);
        firebaseEnabled = true;
      } catch (error) {
        debugPrint('CampusBoard Firebase web initialization failed: $error');
      }
    }
  } else if (firebaseOptions != null) {
    try {
      await Firebase.initializeApp(options: firebaseOptions);
      firebaseEnabled = true;
    } catch (error) {
      debugPrint('CampusBoard Firebase initialization failed: $error');
    }
  } else {
    try {
      await Firebase.initializeApp();
      firebaseEnabled = true;
    } catch (error) {
      debugPrint('CampusBoard Firebase initialization skipped: $error');
    }
  }

  final firestoreService = FirestoreService(
    localStorage: localStorageService,
    firebaseEnabled: firebaseEnabled,
  );
  final authService = AuthService(
    firebaseAuth: firebaseEnabled ? firebase_auth.FirebaseAuth.instance : null,
  );

  runApp(
    CampusBoardApp(
      localStorageService: localStorageService,
      firestoreService: firestoreService,
      authService: authService,
      firebaseEnabled: firebaseEnabled,
    ),
  );
}

class CampusBoardApp extends StatelessWidget {
  const CampusBoardApp({
    super.key,
    required this.localStorageService,
    required this.firestoreService,
    required this.authService,
    required this.firebaseEnabled,
  });

  final LocalStorageService localStorageService;
  final FirestoreService firestoreService;
  final AuthService authService;
  final bool firebaseEnabled;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalStorageService>.value(value: localStorageService),
        Provider<FirestoreService>.value(value: firestoreService),
        Provider<AuthService>.value(value: authService),
        Provider<bool>.value(value: firebaseEnabled),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            authService: authService,
            firestoreService: firestoreService,
            localStorageService: localStorageService,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, EventProvider>(
          create: (_) => EventProvider(firestoreService: firestoreService),
          update: (_, authProvider, eventProvider) {
            final provider =
                eventProvider ?? EventProvider(firestoreService: firestoreService);
            if (authProvider.status == AuthStatus.authenticated) {
              Future<void>.microtask(provider.startListening);
            } else {
              Future<void>.microtask(provider.stopListeningAndClear);
            }
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'CampusBoard',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.splash:
              return _fade(const SplashScreen(), settings);
            case AppRoutes.welcome:
              return _fade(const WelcomeScreen(), settings);
            case AppRoutes.login:
              return _slide(const LoginScreen(), settings);
            case AppRoutes.register:
              return _slide(const RegisterScreen(), settings);
            case AppRoutes.verifyEmail:
              return _slide(const EmailVerificationScreen(), settings);
            case AppRoutes.onboarding:
              return _slide(const OnboardingScreen(), settings);
            case AppRoutes.dashboard:
              return _fade(const DashboardScreen(), settings);
            case AppRoutes.eventDetail:
              return _slide(const EventDetailScreen(), settings);
            case AppRoutes.myEvents:
              return _fade(const MyEventsScreen(), settings);
            case AppRoutes.map:
              return _fade(const MapScreen(), settings);
            case AppRoutes.calendar:
              return _fade(const CalendarScreen(), settings);
            case AppRoutes.createEvent:
              return _fade(const CreateEventScreen(), settings);
            case AppRoutes.settings:
              return _fade(const SettingsScreen(), settings);
            case AppRoutes.profile:
              return _slide(const ProfileScreen(), settings);
            case AppRoutes.notifications:
              return _slide(const NotificationsScreen(), settings);
            case AppRoutes.eventPrefs:
              return _slide(const PreferencesScreen(), settings);
            case AppRoutes.privacy:
              return _slide(const PrivacyScreen(), settings);
            case AppRoutes.faq:
              return _slide(const FaqScreen(), settings);
            case AppRoutes.feedback:
              return _slide(const FeedbackScreen(), settings);
            case AppRoutes.about:
              return _slide(const AboutScreen(), settings);
            default:
              return _fade(const WelcomeScreen(), settings);
          }
        },
      ),
    );
  }

  static PageRoute<dynamic> _fade(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  static PageRoute<dynamic> _slide(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }

  static ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'DMSans',
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: Color(0xFF7B9FD4),
        surface: Color(0xFF111318),
        onSurface: Color(0xFFE8E6E2),
      ),
      scaffoldBackgroundColor: const Color(0xFF0B0C0F),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0B0C0F),
        foregroundColor: Color(0xFFE8E6E2),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: 'DMSans', color: Color(0xFFE8E6E2)),
        bodyMedium: TextStyle(fontFamily: 'DMSans', color: Color(0xFFE8E6E2)),
        bodySmall: TextStyle(fontFamily: 'DMSans', color: Color(0xFF8A8C96)),
        titleLarge:
            TextStyle(fontFamily: 'DMSerifDisplay', color: Color(0xFFE8E6E2)),
        titleMedium:
            TextStyle(fontFamily: 'DMSerifDisplay', color: Color(0xFFE8E6E2)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF161820),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1F2130)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1F2130)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: const Color(0xFF7B9FD4).withOpacity(0.6)),
        ),
        hintStyle:
            const TextStyle(color: Color(0xFF52545E), fontFamily: 'DMSans'),
        labelStyle:
            const TextStyle(color: Color(0xFF8A8C96), fontFamily: 'DMSans'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B9FD4),
          foregroundColor: const Color(0xFF0B0C0F),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE8E6E2),
          side: const BorderSide(color: Color(0xFF1F2130)),
          textStyle: const TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1D1F28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titleTextStyle: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE8E6E2),
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 13,
          color: Color(0xFF8A8C96),
          height: 1.5,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_state.dart';
import 'utils/routes.dart';
import 'models/user_model.dart';

// Screens - Auth
import 'screens/auth/splash_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/onboarding_screen.dart';

// Screens - Core
import 'screens/core/dashboard_screen.dart';
import 'screens/core/event_detail_screen.dart';
import 'screens/core/my_events_screen.dart';
import 'screens/core/map_screen.dart';
import 'screens/core/calendar_screen.dart';

import 'screens/admin/create_event_screen.dart';

// Screens - Settings
import 'screens/settings/settings_screen.dart';
import 'screens/settings/profile_screen.dart';
import 'screens/settings/notifications_screen.dart';
import 'screens/settings/preferences_screen.dart';
import 'screens/settings/privacy_screen.dart';
import 'screens/settings/faq_screen.dart';
import 'screens/settings/feedback_screen.dart';
import 'screens/settings/about_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const CampusBoardApp());
}

class CampusBoardApp extends StatefulWidget {
  const CampusBoardApp({super.key});

  @override
  State<CampusBoardApp> createState() => _CampusBoardAppState();
}

class _CampusBoardAppState extends State<CampusBoardApp> {
  final _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      state: _appState,
      child: MaterialApp(
        title: 'CampusBoard',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),

        // ── Named Routes (requirement) ──────────────────────────
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            // Auth
            case AppRoutes.splash:
              return _fade(const SplashScreen(), settings);

            case AppRoutes.welcome:
              return _fade(const WelcomeScreen(), settings);

            case AppRoutes.login:
              return _slide(const LoginScreen(), settings);

            case AppRoutes.onboarding:
              // Receives: { email: String, seed: User }
              return _slide(const OnboardingScreen(), settings);

            // Dashboard — receives User on first push from onboarding
            case AppRoutes.dashboard:
              return _buildDashboardRoute(settings);

            case AppRoutes.eventDetail:
              return _slide(const EventDetailScreen(), settings);

            case AppRoutes.myEvents:
              return _fade(const MyEventsScreen(), settings);

            case AppRoutes.map:
              return _fade(const MapScreen(), settings);

            case AppRoutes.calendar:
              return _fade(const CalendarScreen(), settings);

            // Admin
            case AppRoutes.createEvent:
              return _fade(const CreateEventScreen(), settings);

            // Settings
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

        // Intercept navigations that carry a User argument (after onboarding)
        navigatorObservers: [_AppStateObserver(_appState)],
      ),
    );
  }

  // ── Route builder helpers ────────────────────────────────────

  Route _buildDashboardRoute(RouteSettings settings) {
    // If onboarding passes user data, set it before showing the dashboard
    final arg = settings.arguments;
    if (arg is Map<String, dynamic>) {
      final user = arg['user'] as User?;
      final email = arg['email'] as String?;
      if (user != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _appState.setAccount(user, email: email);
        });
      }
    } else if (arg is User) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _appState.setAccount(arg);
      });
    }
    return _fade(const DashboardScreen(), settings);
  }

  PageRoute _fade(Widget page, RouteSettings settings) => PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      );

  PageRoute _slide(Widget page, RouteSettings settings) => PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      );

  // ── Theme ────────────────────────────────────────────────────

  ThemeData _buildTheme() {
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
              fontFamily: 'DMSans', fontWeight: FontWeight.w600),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE8E6E2),
          side: const BorderSide(color: Color(0xFF1F2130)),
          textStyle: const TextStyle(
              fontFamily: 'DMSans', fontWeight: FontWeight.w500),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1D1F28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titleTextStyle: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE8E6E2)),
        contentTextStyle: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 13,
            color: Color(0xFF8A8C96),
            height: 1.5),
      ),
    );
  }
}

// ── Navigator observer: sets account when dashboard args contain a User ──────

class _AppStateObserver extends NavigatorObserver {
  final AppState _state;
  _AppStateObserver(this._state);

  void _handleDashboardArgs(dynamic args) {
    if (args is Map<String, dynamic>) {
      final user = args['user'] as User?;
      final email = args['email'] as String?;
      if (user != null) _state.setAccount(user, email: email);
    } else if (args is User) {
      _state.setAccount(args);
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route.settings.name == AppRoutes.dashboard) {
      _handleDashboardArgs(route.settings.arguments);
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute?.settings.name == AppRoutes.dashboard) {
      _handleDashboardArgs(newRoute?.settings.arguments);
    }
  }
}

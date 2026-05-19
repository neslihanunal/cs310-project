import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:campusboard_app/main.dart';
import 'package:campusboard_app/services/auth_service.dart';
import 'package:campusboard_app/services/firestore_service.dart';
import 'package:campusboard_app/services/local_storage_service.dart';

void main() {
  testWidgets('CampusBoard splash renders', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    final localStorageService = await LocalStorageService.create();
    final firestoreService = FirestoreService(
      localStorage: localStorageService,
      firebaseEnabled: false,
    );
    final authService = AuthService();

    await tester.pumpWidget(
      CampusBoardApp(
        localStorageService: localStorageService,
        firestoreService: firestoreService,
        authService: authService,
        firebaseEnabled: false,
      ),
    );

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to CampusBoard'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}

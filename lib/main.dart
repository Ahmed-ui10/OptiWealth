import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'locale_provider.dart';
import 'currency_provider.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'presentation/login_screen.dart';
import 'presentation/dashboard_screen.dart';
import 'presentation/notifications_screen.dart';

// Main entry point of the application
void main() async {
  // Ensure Flutter binding is initialized for platform plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local notifications plugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Request notification permissions if they are disabled
  if (await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled() ==
      false) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Check if user is already logged in
  final authService = AuthService();
  final savedUserId = await authService.getSavedUserId(); // Retrieve saved user ID from shared preferences
  runApp(MyApp(savedUserId: savedUserId));
}

// Main application widget
class MyApp extends StatelessWidget {
  final int? savedUserId; // Existing user ID if logged in, null otherwise
  const MyApp({Key? key, this.savedUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Provide global providers to the entire app
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()), // Language localization
        ChangeNotifierProvider(create: (_) => CurrencyProvider()), // Currency management
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            title: 'OptiWealth',
            theme: ThemeData(primarySwatch: Colors.blue),
            locale: localeProvider.locale, // Dynamically set app language
            supportedLocales: const [Locale('en'), Locale('ar')], // English and Arabic supported
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate, // Material component translations
              GlobalWidgetsLocalizations.delegate, // Widget translations
            ],
            navigatorKey: NotificationService.navigatorKey, // For navigation from notifications
            // Handle deep links / routes
            onGenerateRoute: (settings) {
              if (settings.name == '/notifications') {
                final userId = settings.arguments as int;
                return MaterialPageRoute(
                  builder: (_) => NotificationsScreen(userId: userId),
                );
              }
              return null;
            },
            // Show Dashboard if user is logged in, otherwise show Login screen
            home: savedUserId != null
                ? DashboardScreen(userId: savedUserId!)
                : LoginScreen(),
            debugShowCheckedModeBanner: false, // Hide debug banner
          );
        },
      ),
    );
  }
}
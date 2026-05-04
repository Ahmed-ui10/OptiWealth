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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  if (await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled() ==
      false) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  final authService = AuthService();
  final savedUserId = await authService.getSavedUserId();
  runApp(MyApp(savedUserId: savedUserId));
}

class MyApp extends StatelessWidget {
  final int? savedUserId;
  const MyApp({Key? key, this.savedUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return MaterialApp(
            title: 'OptiWealth',
            theme: ThemeData(primarySwatch: Colors.blue),
            locale: localeProvider.locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            navigatorKey: NotificationService.navigatorKey,
            onGenerateRoute: (settings) {
              if (settings.name == '/notifications') {
                final userId = settings.arguments as int;
                return MaterialPageRoute(
                  builder: (_) => NotificationsScreen(userId: userId),
                );
              }
              return null;
            },
            home: savedUserId != null
                ? DashboardScreen(userId: savedUserId!)
                : LoginScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
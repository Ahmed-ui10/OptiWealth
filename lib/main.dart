import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'locale_provider.dart';
import 'services/auth_service.dart';
import 'presentation/login_screen.dart';
import 'presentation/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  final savedUserId = await authService.getSavedUserId();
  runApp(MyApp(savedUserId: savedUserId));
}

class MyApp extends StatelessWidget {
  final int? savedUserId;
  const MyApp({Key? key, this.savedUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
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
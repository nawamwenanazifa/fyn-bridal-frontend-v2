import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/go_router.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();  // Load saved token and user data
  runApp(const FynBridalsApp());
}

class FynBridalsApp extends StatelessWidget {
  const FynBridalsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Fyn Bridals',
      theme: FynBridalTheme.theme,
      routerConfig: AppRouter.router,
    );
  }
}
import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/go_router.dart';

void main() => runApp(const FynBridalsApp());

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
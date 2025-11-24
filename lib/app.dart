import 'package:flutter/material.dart';
import 'presentation/qr/qr_init_screen.dart';

class ControlApp extends StatelessWidget {
  const ControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QrInitScreen(),
    );
  }
}

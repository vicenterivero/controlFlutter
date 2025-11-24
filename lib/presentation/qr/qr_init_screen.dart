import 'package:flutter/material.dart';
import '../../core/config.dart';
import '../login/user_login_screen.dart';
import 'qr_scanner_screen.dart';

class QrInitScreen extends StatefulWidget {
  const QrInitScreen({super.key});

  @override
  State<QrInitScreen> createState() => _QrInitScreenState();
}

class _QrInitScreenState extends State<QrInitScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _scan);
  }

  Future<void> _scan() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );

    if (result != null) {
      AppConfig.updateBase(result);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Escaneando...")),
    );
  }
}

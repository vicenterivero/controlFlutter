import 'package:flutter/material.dart';
import '../../data/api/control_api.dart';
import '../qr/qr_init_screen.dart';
import 'controller/control_controller.dart';
import 'layout/control_layout.dart';

class ControlScreen extends StatefulWidget {
  final String usuario;
  final int jugador;

  const ControlScreen({
    super.key,
    required this.usuario,
    required this.jugador,
  });

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  late ControlController controller;

  @override
  void initState() {
    super.initState();
    controller = ControlController(
      usuario: widget.usuario,
      api: ControlApi(),
      logoutCallback: _logout,
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const QrInitScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorJugador = widget.jugador == 1
        ? const Color(0xFF0192B2)
        : const Color(0xFFB20101);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, colorJugador],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ControlLayout(
            usuario: widget.usuario,
            onPressStart: controller.onPressStart,
            onPressEnd: controller.onPressEnd,
            onLogout: _logout,
          ),
        ),
      ),
    );
  }
}

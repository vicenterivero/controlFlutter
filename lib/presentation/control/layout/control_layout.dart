import 'package:flutter/material.dart';
import '../widgets/control_button.dart';

class ControlLayout extends StatelessWidget {
  final String usuario;
  final void Function(String) onPressStart;
  final void Function(String) onPressEnd;
  final VoidCallback onLogout;

  const ControlLayout({
    super.key,
    required this.usuario,
    required this.onPressStart,
    required this.onPressEnd,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // IZQUIERDA
        Column(
          children: [
            Text(usuario, style: const TextStyle(color: Colors.white)),
            IconButton(
              icon: const Icon(Icons.restart_alt, color: Colors.white),
              iconSize: 40,
              onPressed: onLogout,
            ),
            const SizedBox(height: 90),
            ControlButton(
              icon: Icons.arrow_left,
              label: "Izquierda",
              onPressStart: onPressStart,
              onPressEnd: onPressEnd,
            ),
          ],
        ),

        // ARRIBA
        Column(
          children: [
            const SizedBox(height: 130),
            ControlButton(
              icon: Icons.arrow_drop_up,
              label: "Arriba",
              onPressStart: onPressStart,
              onPressEnd: onPressEnd,
            ),
          ],
        ),

        // DERECHA + HABILIDAD
        Column(
          children: [
            ControlButton(
              icon: Icons.adjust,
              label: "Habilidad",
              onPressStart: onPressStart,
              onPressEnd: onPressEnd,
            ),
            const SizedBox(height: 20),
            ControlButton(
              icon: Icons.arrow_right,
              label: "Derecha",
              onPressStart: onPressStart,
              onPressEnd: onPressEnd,
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final void Function(String) onPressStart;
  final void Function(String) onPressEnd;

  const ControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressStart,
    required this.onPressEnd,
  });

  void _vibrate() {
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) {
        _vibrate();
        onPressStart(label);
      },
      onPanStart: (_) {
      },
      onPanEnd: (_) {
        onPressEnd(label);
      },
      onPanCancel: () {
        onPressEnd(label);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.all(8),
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, size: 80, color: Colors.black87),
      ),
    );
  }
}

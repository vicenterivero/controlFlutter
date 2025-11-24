import '../../../data/api/control_api.dart';

class ControlController {
  final String usuario;
  final ControlApi api;
  final Function logoutCallback;

  final Map<String, bool> _isPressedMap = {};

  ControlController({
    required this.usuario,
    required this.api,
    required this.logoutCallback,
  });

  Future<void> _send(String button, bool presionar) async {
    try {
      final res = await api.sendAction(usuario, button, presionar);

      if (res.statusCode != 200) {
        logoutCallback();
      }
    } catch (_) {
      logoutCallback();
    }
  }

  void onPressStart(String button) {
    _isPressedMap[button] = true;

    Future(() async {
      while (_isPressedMap[button] == true) {
        await _send(button, true);
        await Future.delayed(const Duration(milliseconds: 50));
      }

      await _send(button, false);
    });
  }

  void onPressEnd(String button) {
    _isPressedMap[button] = false;
  }
}

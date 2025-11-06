import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Forzar orientación horizontal
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  runApp(const ControlApp());
}

class ControlApp extends StatefulWidget {
  const ControlApp({super.key});

  @override
  State<ControlApp> createState() => _ControlAppState();
}

class _ControlAppState extends State<ControlApp> {
  String? _usuario;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _usuario == null
          ? Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Ingresa tu nombre de usuario",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "ej. vicente",
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_controller.text.isNotEmpty) {
                            await _registrarUsuario(_controller.text);
                            setState(() => _usuario = _controller.text);
                          }
                        },
                        child: const Text("Conectarse"),
                      )
                    ],
                  ),
                ),
              ),
            )
          : ControlScreen(usuario: _usuario!),
    );
  }

  Future<void> _registrarUsuario(String nombre) async {
    const apiUrl =
        "http://172.30.3.163:5000/asignar_usuario"; // ⚠️ Cambia por la IP de tu PC
    try {
      debugPrint("nombre: $nombre");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"usuario": nombre, "dispositivo": "telefono"}),
      );
      debugPrint("Respuesta registro: ${response.body}");
    } catch (e) {
      debugPrint("Error al registrar usuario: $e");
    }
  }
}

class ControlScreen extends StatefulWidget {
  final String usuario;
  const ControlScreen({super.key, required this.usuario});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  final String apiUrl = "http://172.30.3.163:5000/accion"; // ⚠️ Cambia IP aquí

  // Estado individual por botón
  final Map<String, bool> _isPressedMap = {};

  Future<void> _sendButtonAction(String button, {bool presionar = true}) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuario": widget.usuario,
          "boton": button,
          "accion": presionar ? "presionar" : "soltar"
        }),
      );

      if (response.statusCode == 200) {
        debugPrint(
            "✅ ${widget.usuario} ${presionar ? 'presionó' : 'soltó'}: $button");
      } else {
        debugPrint("⚠️ Error (${response.statusCode}): ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Error al enviar acción: $e");
    }
  }

  void _startSending(String button) {
    _isPressedMap[button] = true;
    debugPrint("▶️ Iniciando envío continuo para $button");

    // Iniciar envío repetido mientras el botón esté presionado
    Future(() async {
      while (_isPressedMap[button] == true) {
        await _sendButtonAction(button, presionar: true);
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Cuando se suelta, enviar acción "soltar"
      await _sendButtonAction(button, presionar: false);
    });
  }

  void _stopSending(String button) {
    debugPrint("🛑 Se soltó el botón $button");
    _isPressedMap[button] = false;
  }

  // --- Botón circular ---
  Widget _circleButton(IconData icon, String label) {

    return GestureDetector(
      onTapDown: (_) => _startSending(label),
      onTapUp: (_) => _stopSending(label),
      onTapCancel: () => _stopSending(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.all(8),
        width: 100,
        height: 100,
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
        child: Icon(
          icon,
          size: 80,
          color: Colors.black87,
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, // punto de inicio
          end: Alignment.bottomRight, // punto final del degradado
          colors: [
            Color(0xFF000000), // negro
            Color.fromARGB(255, 1, 146, 178), // rojo oscuro
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // --- Controles de flechas ---
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _circleButton(Icons.arrow_drop_up, "Arriba"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circleButton(Icons.arrow_left, "Izquierda"),
                    const SizedBox(width: 80),
                    _circleButton(Icons.arrow_right, "Derecha"),
                  ],
                ),
                _circleButton(Icons.arrow_drop_down, "Abajo"),
              ],
            ),

            // --- Botones de acciones ---
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _circleButton(Icons.watch, "Reloj"),
                    const SizedBox(width: 50),
                    _circleButton(Icons.flash_on, "Rayo"),
                  ],
                ),
                const SizedBox(height: 20),
                _circleButton(Icons.adjust, "Proyectil"),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}}
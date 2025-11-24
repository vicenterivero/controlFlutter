import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';

/// Variable global que contiene la base (protocol + ip + puerto)
String baseAddress = 'http://172.30.3.163:5000';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Forzar orientación horizontal
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.landscapeRight,
  //   DeviceOrientation.landscapeLeft,
  // ]);
  runApp(const ControlApp());
}

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

/// Pantalla inicial — primero escanea el QR
class QrInitScreen extends StatefulWidget {
  const QrInitScreen({super.key});

  @override
  State<QrInitScreen> createState() => _QrInitScreenState();
}

class _QrInitScreenState extends State<QrInitScreen> {
  @override
  void initState() {
    super.initState();
    // Abre escáner automáticamente al cargar
    Future.delayed(Duration.zero, _openQrScanner);
  }

  Future<void> _openQrScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );

    if (result != null && result.isNotEmpty) {
      _updateBaseFromQr(result);
      // Navegar al login de usuario
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserLoginScreen()),
        );
      }
    } else {
      // Si no escanea nada, permite reintentar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se detectó ningún QR. Intenta de nuevo.'),
          ),
        );
        Future.delayed(const Duration(seconds: 2), _openQrScanner);
      }
    }
  }

  void _updateBaseFromQr(String raw) {
    String candidate = raw.trim();
    if (candidate.startsWith('http://') || candidate.startsWith('https://')) {
      baseAddress = candidate;
    } else if (candidate.contains(':')) {
      baseAddress = 'http://$candidate';
    } else {
      baseAddress = 'http://$candidate:5000';
    }

    if (baseAddress.endsWith('/')) {
      baseAddress = baseAddress.substring(0, baseAddress.length - 1);
    }

    debugPrint('🔧 baseAddress actualizada a: $baseAddress');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Abriendo cámara para escanear QR...",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

/// Pantalla para ingresar usuario
class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  List<DeviceOrientation> _previousOrientations = [];

  @override
  void initState() {
    super.initState();

    // ✅ Forzar orientación SOLO aquí (ej. vertical)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  final TextEditingController _controller = TextEditingController();
  String? _usuario;

  Future<int> _registrarUsuario(String nombre) async {
    final apiUrl = '$baseAddress/asignar_usuario';
    try {
      debugPrint("nombre: $nombre");
      debugPrint("Registrando en: $apiUrl");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"usuario": nombre, "dispositivo": "telefono"}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return data["jugador"];
      }
      return 0;
    } catch (e) {
      debugPrint("Error al registrar usuario: $e");
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF000000), Color.fromARGB(255, 1, 146, 178)],
          ),
        ),

        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Conectado a: ${baseAddress.replaceAll('http://', '')}",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                "¡Bienvenido a Vivir o Morir!",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Ingresa tu nombre de usuario",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "ej. Rico 6000",
                  hintStyle: TextStyle(color: Colors.white54),

                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_controller.text.isNotEmpty) {
                    int userOk = await _registrarUsuario(_controller.text);
                    setState(() => _usuario = _controller.text);
                    if (mounted && userOk != 0) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ControlScreen(
                            usuario: _usuario!,
                            jugador: userOk,
                          ),
                        ),
                      );
                    } else {
                      // ✅ MOSTRAR ALERTA
                      if (mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Error"),
                            content: const Text(
                              "No fue posible registrarte. Intenta de nuevo.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  }
                },
                child: const Text(
                  "Conectarse",
                  style: TextStyle(color: Color.fromARGB(255, 1, 146, 178)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pantalla principal de control remoto
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
  final Map<String, bool> _isPressedMap = {};

  Future<void> _sendButtonAction(String button, {bool presionar = true}) async {
    final apiUrl = '$baseAddress/accion';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuario": widget.usuario,
          "boton": button,
          "accion": presionar ? "presionar" : "soltar",
        }),
      );

      if (response.statusCode == 200) {
        debugPrint(
          "✅ ${widget.usuario} ${presionar ? 'presionó' : 'soltó'}: $button",
        );
      } else {
        debugPrint("⚠️ Error (${response.statusCode}): ${response.body}");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const QrInitScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("❌ Error al enviar acción: $e");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const QrInitScreen()),
        (route) => false,
      );
    }
  }

  void _startSending(String button) {
    _isPressedMap[button] = true;
    Future(() async {
      while (_isPressedMap[button] == true) {
        await _sendButtonAction(button, presionar: true);
        await Future.delayed(const Duration(milliseconds: 50));
      }
      await _sendButtonAction(button, presionar: false);
    });
  }

  void _stopSending(String button) {
    _isPressedMap[button] = false;
  }

  Widget _circleButton(IconData icon, String label) {
    return GestureDetector(
      onTapDown: (_) => _startSending(label),
      onTapUp: (_) => _stopSending(label),
      onTapCancel: () => _stopSending(label),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF000000),
              widget.jugador == 1
                  ? Color.fromARGB(255, 1, 146, 178)
                  : Color.fromARGB(255, 178, 1, 1),
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // --- Controles de flechas ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        widget.usuario,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.restart_alt),
                        color: Colors.white,
                        iconSize: 40,
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QrInitScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      const SizedBox(height: 150),
                      _circleButton(Icons.arrow_left, "Izquierda"),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  const SizedBox(height: 130),

                  _circleButton(Icons.arrow_drop_up, "Arriba"),
                ],
              ),
              // --- Controles de flechas ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 150), // Para alinearlo en diagonal
                      _circleButton(Icons.arrow_right, "Derecha"),
                    ],
                  ),
                  Column(children: [_circleButton(Icons.adjust, "Habilidad")]),
                ],
              ),
              // --- Botones de acciones ---
            ],
          ),
        ),
      ),
    );
  }
}

/// Pantalla de escaneo QR sin allowDuplicates
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _detected = false;
  final MobileScannerController cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();

    // ✅ Forzar orientación SOLO en esta pantalla (horizontal)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    // ✅ Restaurar orientación al salir
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,

    // ]);
    cameraController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Escanear QR'),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.flash_on),
      //       onPressed: () => cameraController.toggleTorch(),
      //     ),
      //     IconButton(
      //       icon: const Icon(Icons.cameraswitch),
      //       onPressed: () => cameraController.switchCamera(),
      //     ),
      //   ],
      // ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_detected) return;
              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;
              final raw = barcodes.first.rawValue;
              if (raw == null) return;
              _detected = true;
              debugPrint('QR detectado: $raw');
              Navigator.of(context).pop(raw);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(12),
              child: const Text(
                'Apunta al QR para iniciar el control',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

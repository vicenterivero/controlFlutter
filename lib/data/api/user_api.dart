import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config.dart';

class UserApi {
  Future<int> registerUser(String name) async {
    final url = "${AppConfig.baseAddress}/asignar_usuario";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"usuario": name, "dispositivo": "telefono"}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["jugador"];
    }

    return 0;
  }
}

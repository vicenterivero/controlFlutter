import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config.dart';

class ControlApi {
  Future<http.Response> sendAction(String usuario, String boton, bool presionar) async {
    final url = "${AppConfig.baseAddress}/accion";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "usuario": usuario,
        "boton": boton,
        "accion": presionar ? "presionar" : "soltar",
      }),
    );

    return response;
  }
}

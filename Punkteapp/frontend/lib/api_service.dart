import 'package:http/http.dart' as http;
import 'config.dart';

Future<void> testApi() async {
  final response = await http.get(Uri.parse("$apiBaseUrl/api/hello"));
  print(response.body);
}   
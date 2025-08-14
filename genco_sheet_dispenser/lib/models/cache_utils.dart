import 'dart:convert';
import 'dart:io';

Future<void> saveMapToFile(Map<String, dynamic> data, String filePath) async {
  final file = File(filePath);
  final jsonString = jsonEncode(data);
  await file.writeAsString(jsonString);
}

Future<Map<String, dynamic>> loadFileToMap(String filePath) async {
  final file = File(filePath);
  final jsonString = file.readAsStringSync();
  return jsonDecode(jsonString);
}

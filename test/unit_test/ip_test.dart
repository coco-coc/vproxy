import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('test https://ipapi.co/json', () async {
    // get a response
    final response = await http.get(Uri.parse('https://ipapi.co/json'));
    print(response.body);
  });
}

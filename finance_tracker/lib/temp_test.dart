import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String apiUrl = "https://script.google.com/macros/s/AKfycbyiCgsCBuk8wMzJReISNte_fV3lYNXAdDfvfTSbPig9k-qKC9gU0VinQwvbaBwcZ9737Q/exec";
  const String apiToken = "694ec953e60c832280e4316f7d02b261";

  print("Testing connection to: $apiUrl");

  try {
     final uri = Uri.parse(apiUrl);
      final body = {
        'token': apiToken,
        'action': 'fetch',
      };

    print("Sending POST request (simple)...");
    final response = await http.post(uri, body: body);

    print("Response Status Code: ${response.statusCode}");
    print("Response Body Preview: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}");

    if (response.statusCode == 200) {
        if (response.body.trim().startsWith("<!DOCTYPE") || response.body.trim().startsWith("<html")) {
            print("ERROR: Received HTML response. This usually means the script is not accessible to 'Anyone' or the URL is incorrect (e.g. /dev instead of /exec).");
        } else {
            try {
                final json = jsonDecode(response.body);
                print("SUCCESS: Valid JSON received.");
                print("Data: $json");
            } catch (e) {
                print("ERROR: Failed to decode JSON: $e");
            }
        }
    } else {
        print("ERROR: HTTP Status ${response.statusCode}");
    }

  } catch (e) {
    print("FATAL ERROR: $e");
  }
}

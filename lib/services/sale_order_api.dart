import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchSalesOrderPendingReport() async {
  const String url =
      'https://zeemax.regenterp.com/api/method/frappe.desk.query_report.run?report_name=Sales%20Order%20Pending%20Report&limit_page_length=50000';
  const String token = 'ed4bbea42d574b6:11d2aaabc1967e0';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'token $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    // Decode the JSON response
    final data = json.decode(response.body);
    print(response.body);
    print(response.statusCode);
    print(data); // Debug line to inspect the response

    // Check the structure and adjust the access accordingly
    // If the result is nested, you may need to navigate through the structure
    if (data['message'] != null && data['message']['result'] != null) {
      return data['message']['result']; // Ensure this is a list
    } else {
      throw Exception('Unexpected data structure: $data');
    }
  } else {
    throw Exception('Failed to load report');
  }
}

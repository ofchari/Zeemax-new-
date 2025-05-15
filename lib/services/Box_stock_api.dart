import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/json_model/Box_stock_report_json.dart';

Future<Box?> fetchBoxStockReport() async {
  final url = Uri.parse(
    'https://zeemax.regenterp.com/api/method/frappe.desk.query_report.run?report_name=Box%20Stock%20Report&limit_page_length=50000',
  );

  final headers = {
    "Authorization": "token ed4bbea42d574b6:11d2aaabc1967e0",
    "Content-Type": "application/json"
  };

  try {
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // Decode the JSON response
      final jsonResponse = jsonDecode(response.body);

      // Parse the JSON into Box model
      return Box.fromJson(jsonResponse);
    } else {
      print("Failed to load data. Status code: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error fetching Box Stock Report data: $e");
    return null;
  }
}

/// Example usage of the fetchBoxStockReport function ///

void getBoxStockReport() async {
  Box? boxData = await fetchBoxStockReport();

  if (boxData != null) {
    print("Data fetched successfully.");
    // Access data as needed, e.g., boxData.message?.result
  } else {
    print("Failed to fetch data.");
  }
}

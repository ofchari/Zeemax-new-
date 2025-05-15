import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/json_model/order_json.dart';

Future<List<Datumord>> fetchOrder() async {
  final response = await http.get(
      Uri.parse(
          'https://zeemax.regenterp.com/api/resource/Order Form?fields=["name",%22company%22,%22date%22,%22buyer%22,%22due_date%22,%22order_no%22,"workflow_state","consignee","priority","product","all_size"]&limit_page_length=50000'),
      headers: {"Authorization": "token ed4bbea42d574b6:11d2aaabc1967e0"});
  if (response.statusCode == 200) {
    print(response.body);
    print(response.statusCode);
    List<dynamic> dataOrd = jsonDecode(response.body)['data'];
    return dataOrd.map((e) => Datumord.fromJson(e)).toList();
  } else {
    // Error Status through //
    throw Exception("Failed to load data ${response.statusCode}");
  }
}

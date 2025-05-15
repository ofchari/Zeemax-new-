import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/json_model/cutting_inward_json.dart';

Future<List<Datum>> fetchCuttingData() async {
  final response = await http.get(
      Uri.parse(
          'https://zeemax.regenterp.com/api/resource/Cutting%20Inward?fields=[%22name%22,%22subcon%22,%22process_name%22,%22work_ord_no%22,%22date%22,%22fi_no%22,%22workflow_state%22,%22employee%22,%22warehouse%22]&limit_page_length=50000'),
      headers: {"Authorization": "token ed4bbea42d574b6:11d2aaabc1967e0"});
  if (response.statusCode == 200) {
    print(response.body);
    print(response.statusCode);
    // Handle the Responses //
    List<dynamic> cuttingInfo = jsonDecode(response.body)['data'];
    print(response.body);
    print(response.statusCode);
    return cuttingInfo.map((e) => Datum.fromJson(e)).toList();
  } else {
    throw Exception("Failed to load data ${response.statusCode}");
  }
}

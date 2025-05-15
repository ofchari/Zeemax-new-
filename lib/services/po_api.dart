// services/po_api.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../model/json_model/po_json.dart';

Future<List<Datumpo>> fetchPo() async {
  HttpClient client = HttpClient();
  client.badCertificateCallback =
  ((X509Certificate cert, String host, int port) => true);
  IOClient ioClient = IOClient(client);

  final response = await ioClient.get(
    Uri.parse(
      'https://zeemax.regenterp.com/api/resource/PO?fields=["name",%22company%22,%22supplier%22,%22type%22,%22order_type%22,%22due_date%22,%22work_ord_no%22,%22workflow_state%22]&limit_page_length=50000',
    ),
    headers: {"Authorization": "token ed4bbea42d574b6:11d2aaabc1967e0"},
  );

  if (response.statusCode == 200) {
    List<dynamic> dataPo = jsonDecode(response.body)['data'];
    return dataPo.map((e) => Datumpo.fromJson(e)).toList();
  } else {
    // Error Status through //
    throw Exception("Failed to load data ${response.statusCode}");
  }
}

// If you need to update a PO's workflow state
Future<void> updateWorkflowState(String poName, String newState) async {
  HttpClient client = HttpClient();
  client.badCertificateCallback =
  ((X509Certificate cert, String host, int port) => true);
  IOClient ioClient = IOClient(client);

  final url = Uri.parse(
    'https://zeemax.regenterp.com/api/resource/PO/$poName',
  );

  final headers = {
    "Authorization": "token ed4bbea42d574b6:11d2aaabc1967e0",
    "Content-Type": "application/json",
  };

  final body = {"workflow_state": newState};

  final response = await ioClient.put(
    url,
    headers: headers,
    body: jsonEncode(body),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update workflow state: ${response.statusCode}');
  }
}
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:zee/view/screens/cutting_inward.dart';
import 'package:zee/view/widgets/text.dart';

import '../widgets/button.dart';
import '../widgets/subhead.dart';

class PdfViewerPage extends StatefulWidget {
  final String name;

  const PdfViewerPage({super.key, required this.name});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late double height;
  late double width;
  String? pdfFilePath;
  bool isLoading = true;
  bool hasError = false;
  String actionData = '';
  String actionTake = '';

  @override
  void initState() {
    super.initState();
    _fetchAndLoadPdf();
    print(widget.name);
  }

  ///  PDF Fetching Logic ///
  Future<void> _fetchAndLoadPdf() async {
    try {
      String apiUrl =
          "https://zeemax.regenterp.com/api/method/frappe.utils.print_format.download_pdf?doctype=Cutting%20Inward&name=${widget.name}&format=Cutting%20Print&no_letterhead=1&letterhead=No%20Letterhead&settings=%7B%7D&_lang=en";

      var headers = {"Authorization": "token ed4bbea42d574b6:11d2aaabc1967e0"};

      var response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        var dir = await getTemporaryDirectory();
        File file = File("${dir.path}/${widget.name}.pdf");
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          pdfFilePath = file.path;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load PDF");
      }
    } catch (e) {
      print("Error fetching PDF: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  ///  PDF Download Logic  ///
  Future<void> _downloadPdf() async {
    try {
      var appDir = await getApplicationDocumentsDirectory();
      String filePath = "${appDir.path}/${widget.name}.pdf";
      await File(pdfFilePath!).copy(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PDF saved to: $filePath"),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print("Error downloading PDF: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to download PDF.")));
    }
  }

  void actionAlerts(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.info,
      title: "Action",
      style: AlertStyle(
        titleStyle: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.green,
          ),
        ),
        descStyle: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.blue,
          ),
        ),
      ),
      desc: "Select the Actions",
      buttons: [
        DialogButton(
          color: Colors.grey.shade200,
          onPressed: () {
            setState(() {
              actionTake = "Approved"; // Approve action
            });
            showAlerts(context);
          },
          child: const MyTextOne(text: "Approve", color: Colors.blue),
        ),
        DialogButton(
          color: Colors.grey.shade200,
          onPressed: () {
            setState(() {
              actionTake = "Rejected"; // Reject action
            });
            workflow_update(); // Call workflow update for "Rejected"
          },
          child: const MyTextOne(text: "Reject", color: Colors.red),
        ),
      ],
    ).show();
  }

  Future<void> workflow_update() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);

    final url = Uri.parse(
      'https://zeemax.regenterp.com/api/resource/Cutting%20Inward/${widget.name}',
    );

    final headers = {
      "Authorization": "token ed4bbea42d574b6:11d2aaabc1967e0",
      "Content-Type": "application/json",
    };

    final body = {"workflow_state": actionTake};

    try {
      final response = await ioClient.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Success: ${response.body}');
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update workflow');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }

  // Alert Popup logic //
  void showAlerts(context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Alert Message",
      style: AlertStyle(
        titleStyle: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.green,
          ),
        ),
        descStyle: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.blue,
          ),
        ),
      ),
      desc: "Are you sure you want to submit?",
      buttons: [
        DialogButton(
          color: Colors.grey.shade200,
          child: GestureDetector(
            onTap: () {
              // Call workflow_update, and after success, navigate to OrderForm page
              workflow_update().then((_) {
                // Navigate to OrderForm page
                Get.offAll(
                  () => CuttingInward(updateWorkflowState: actionTake),
                ); // Pass the updated workflow state to the OrderForm page
              }).catchError((e) {
                // Handle errors if needed
                print("Error updating workflow: $e");
              });
            },
            child: const MyTextOne(text: "Yes", color: Colors.blue),
          ),
          onPressed: () {},
        ),
        DialogButton(
          color: Colors.grey.shade200,
          child: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: const MyTextOne(text: "No", color: Colors.red),
          ),
          onPressed: () {
            // Close dialog
          },
        ),
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Subhead(text: "PDF Cutting", color: Colors.white),
        backgroundColor: Colors.red.shade700,
        centerTitle: true,
        actions: [
          if (!isLoading && pdfFilePath != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadPdf,
              tooltip: "Download PDF",
            ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () {
              setState(() {
                actionAlerts(context);
              });
            },
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Buttons(
                  heigh: height / 22.h,
                  width: width / 4.w,
                  color: Colors.blueGrey,
                  text: "Action",
                  radius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : hasError
                  ? const Center(
                      child: Text(
                        "Failed to load PDF.",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : pdfFilePath != null
                      ? Expanded(child: PDFView(filePath: pdfFilePath!))
                      : const Center(
                          child: Text(
                            "Error: PDF not found.",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
        ],
      ),
    );
  }
}

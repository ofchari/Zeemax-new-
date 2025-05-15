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
import 'package:zee/view/widgets/text.dart';

import '../widgets/button.dart';
import '../widgets/subhead.dart';
import 'order.dart'; // Add this for handling permissions

class Pdforder extends StatefulWidget {
  final String name;

  const Pdforder({super.key, required this.name});

  @override
  State<Pdforder> createState() => _PdforderState();
}

class _PdforderState extends State<Pdforder> {
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
  }

  /// PDF viewer logics //
  Future<void> _fetchAndLoadPdf() async {
    try {
      // Build the API URL with the given name
      String apiUrl =
          "https://zeemax.regenterp.com/api/method/frappe.utils.print_format.download_pdf?doctype=Order%20Form&name=${widget.name}&format=Order%20Form&no_letterhead=1&letterhead=No%20Letterhead&settings=%7B%7D&_lang=en";

      /// Pass the headers with Authorization token
      var headers = {"Authorization": "token ed4bbea42d574b6:11d2aaabc1967e0"};

      // Fetch the PDF from the API
      var response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        // Get temporary directory to save the PDF
        var dir = await getTemporaryDirectory();
        File file = File("${dir.path}/${widget.name}.pdf");

        // Save the fetched PDF
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

  /// Download logics for PDF //
  Future<void> _downloadPdf() async {
    try {
      /// Directory for app-specific internal storage
      var appDir =
          await getApplicationDocumentsDirectory(); // Internal storage directory
      String filePath = "${appDir.path}/${widget.name}.pdf";

      // Copy PDF to the internal app folder
      File(pdfFilePath!).copy(filePath).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("PDF saved to: $filePath"),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    } catch (e) {
      print("Error downloading PDF: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to download PDF.")));
    }
  }

  void actionAlerts(dynamic BuildContext, context) {
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
            // No action here, handled by GestureDetector
          },
          child: GestureDetector(
            onTap: () {
              setState(() {
                actionTake =
                    (actionData == 'Initiated') ? "Approved" : "Authorize";
              });
              showAlerts(context);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: MyTextOne(
                text: (actionData == 'Initiated') ? "Approved" : "Authorize",
                color: Colors.blue,
              ),
            ),
          ),
        ),
        DialogButton(
          color: Colors.grey.shade200,
          onPressed: () {
            // No action here, handled by GestureDetector
          },
          child: GestureDetector(
            onTap: () {
              setState(() {
                actionTake =
                    "Rejected"; // Set actionTake to "Rejected" when "Reject" is clicked
              });
              showAlerts(context);
            },
            child: const MyTextOne(text: "Rejected", color: Colors.red),
          ),
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
      'https://zeemax.regenterp.com/api/resource/Order%20Form/${widget.name}',
    ); // Add / between Order Form and ${widget.name}

    final headers = {
      "Authorization": "token ed4bbea42d574b6:11d2aaabc1967e0",
      "Content-Type": "application/json", // Assuming the server expects JSON
    };

    final body = {
      "workflow_state": actionTake, // Updated to send selected action state
    };

    try {
      final response = await ioClient.put(
        url,
        headers: headers,
        body: jsonEncode(body), // Convert body to JSON string
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Add full logging

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
              workflow_update()
                  .then((_) {
                    // Navigate to OrderForm page
                    Get.offAll(
                      () => OrderForm(updatedWorkflowState: actionTake),
                    ); // Pass the updated workflow state to the OrderForm page
                  })
                  .catchError((e) {
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
    // Define Sizes //
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Subhead(text: "PDF Order Viewer", color: Colors.white),
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
                actionAlerts(BuildContext, context);
              });
            },
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(right: ScreenUtil().setWidth(8.0)),
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/sale_order_api.dart';
import '../widgets/subhead.dart';
import 'home.dart';

class SalesOrderPendingReport extends StatefulWidget {
  const SalesOrderPendingReport({super.key});

  @override
  State<SalesOrderPendingReport> createState() => _SalesOrderPendingReportState();
}

class _SalesOrderPendingReportState extends State<SalesOrderPendingReport> {
  // Helper function to remove HTML tags
  String stripHtmlTags(String htmlText) {
    final exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

  // Helper to convert HTML-tagged values to double safely
  String? formatNumericValue(dynamic value) {
    final cleanValue = stripHtmlTags(value?.toString() ?? '');
    final parsedValue = double.tryParse(cleanValue);
    return parsedValue?.toStringAsFixed(2);
  }

             /// Will pop scope logic
  Future<bool> popScopes(BuildContext context) async {
    return await Get.dialog(
      AlertDialog(
        title: const Text("Are Sure Want to exit? "),
        titleTextStyle: GoogleFonts.poppins(
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.green,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Get.offAll(() => const Home()); // Navigate to BottomNavigation and replace the current page
            },
            child: const Text("Yes", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade500),
            onPressed: () {
              Navigator.pop(context); // Just close the dialog and stay on the current page
            },
            child: const Text("No", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()=>popScopes(context),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () {
              Get.offAll(const Home());
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: const Subhead(text: "Sale Order Pending Report", color: Colors.white),
          backgroundColor: Colors.red.shade700,
          centerTitle: true,
        ),
        body: FutureBuilder<List<dynamic>>(
          future: fetchSalesOrderPendingReport(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No data found'));
            } else {
              // Extracting the report data
              final reportData = snapshot.data!;

              // Create the DataTable
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns:  [
                          DataColumn(label: Text('Order No',style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),)),
                          DataColumn(label: Text('Party No',style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),)),
                          DataColumn(label: Text('Date',style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),)),
                          DataColumn(label: Text('Days',style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),)),
                          DataColumn(label: Text('Party',style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)),)),
                          // DataColumn(label: Text('Status',style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                          DataColumn(label: Text('Item',style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                          DataColumn(label: Text('Style',style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                          DataColumn(label: Text('75',style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                          DataColumn(label: Text('80',style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                          DataColumn(label: Text('85',style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                          DataColumn(label: Text('100',style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                          DataColumn(label: Text('Total quantity',style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500,color: Colors.black)))),
                        ],
                        rows: reportData.map((order) {
                          // Ensure order is a Map and contains necessary keys
                          if (order is Map<String, dynamic>) {
                            return DataRow(cells: [
                              DataCell(Text(order['sale_order_no']?.toString() ?? 'No Order Number')),
                              DataCell(Text(order['party_no'] ?? 'No Party Number')),
                              DataCell(Text(order['date'] ?? 'No Date')),
                              DataCell(Text(order['days']?.toString() ?? 'No Days')),
                              DataCell(Text(order['party'] ?? 'No Party')),
                              /// DataCell(Text(order['status'] ?? 'No Status')),
                              DataCell(Text(order['item'] ?? 'No Item')),
                              DataCell(Text(stripHtmlTags(order['style']?.toString() ?? ''))),
                              DataCell(Text(formatNumericValue(order['75']) ?? '')),
                              DataCell(Text(formatNumericValue(order['80']) ?? '')),
                              DataCell(Text(formatNumericValue(order['85']) ?? '')),
                              DataCell(Text(formatNumericValue(order['100']) ?? '')),
                              DataCell(Text(formatNumericValue(order['total_quantity']) ?? '')),
                            ]);
                          } else {
                            return const DataRow(cells: [
                              DataCell(Text('Invalid order data')),
                              DataCell(Text('')),
                              DataCell(Text('')),
                              DataCell(Text('')),
                              DataCell(Text('')),
                              DataCell(Text('')),
                              /// DataCell(Text('')),
                              DataCell(Text('')),
                              DataCell(Text('')),
                              DataCell(Text('')),
                              DataCell(Text('')),
                              DataCell(Text('')),
                              DataCell(Text('')),
                            ]);
                          }
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

}

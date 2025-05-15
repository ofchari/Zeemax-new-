import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:zee/view/screens/pdf_cutting.dart';

import '../../model/json_model/cutting_inward_json.dart';
import '../../services/cutting_inward_api.dart';
import '../widgets/subhead.dart';
import 'home.dart';

class CuttingInward extends StatefulWidget {
  final String updateWorkflowState;
  const CuttingInward({super.key, required this.updateWorkflowState});

  @override
  State<CuttingInward> createState() => _CuttingInwardState();
}

class _CuttingInwardState extends State<CuttingInward> {
  late double height;
  late double width;
  String actionData = '';
  String actionTake = '';
  int pendingCount = 0; // Variable to store count of pending items
  String filterState = 'Pending'; // Variable to store selected filter state

  Future<void> workflow_update() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);

    final url = Uri.parse(
      'https://zeemax.regenterp.com/api/resource/Cutting%20Inward?fields=[%22name%22,"workflow_state"]&limit_page_length=50000',
    );

    final headers = {
      "Authorization": "token ed4bbea42d574b6:11d2aaabc1967e0",
      "Content-Type": "application/json",
    };

    final body = {"workflow_state": actionTake};

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Success: ${response.body}');
        }
      } else {
        if (kDebugMode) {
          print('Failed with status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        throw Exception('Failed to update workflow');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch data');
    }
  }

  Color _getBackgroundColor(String workflowstate) {
    switch (workflowstate) {
      case 'Initiated':
        return Colors.grey;
      case 'Approved':
        return Colors.orange.shade600;
      case 'Authorized':
        return Colors.green;
      case 'Pending':
        return Colors.red.shade600;
      case 'Rejected':
        return Colors.grey;
      default:
        return Colors.brown;
    }
  }

  /// wiil popscope logic //
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
                  Get.offAll(
                    () => const Home(),
                  ); // Navigate to BottomNavigation and replace the current page
                },
                child: const Text("Yes", style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade500,
                ),
                onPressed: () {
                  Navigator.pop(
                    context,
                  ); // Just close the dialog and stay on the current page
                },
                child: const Text("No", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    workflow_update();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return WillPopScope(
      onWillPop: () => popScopes(context),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () {
              Get.offAll(const Home());
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: const Subhead(text: " Cutting Inward", color: Colors.white),
          backgroundColor: Colors.red.shade700,
          centerTitle: true,
        ),
        body: SizedBox(
          width: width.w,
          child: Column(
            children: [
              SizedBox(height: 10.h),
              // Text at the top showing the selected filter name or pending count
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0.h),
                child: FutureBuilder<List<Datum>>(
                  future: fetchCuttingData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    } else {
                      // Calculate pending count
                      pendingCount = snapshot.data!
                          .where(
                            (cutting) => cutting.workflowState == 'Pending',
                          )
                          .length;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 58.0),
                            child: Text(
                              filterState == 'Pending'
                                  ? "Pending Count: $pendingCount" // Show pending count if filter is 'Pending'
                                  : "Filter: $filterState", // Show filter name otherwise
                              style: GoogleFonts.dmSans(
                                textStyle: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w), // Space between text and icon
                          GestureDetector(
                            onTap: () => _showFilterDialog(),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 80.0),
                              child: Icon(
                                Icons.filter_list,
                                size: 24.sp,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),

              FutureBuilder<List<Datum>>(
                future: fetchCuttingData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  } else {
                    // Apply filtering logic based on the selected filter state
                    List<Datum> filteredData = snapshot.data!;
                    if (filterState == 'Pending') {
                      filteredData = snapshot.data!
                          .where(
                            (cutting) => cutting.workflowState == 'Pending',
                          )
                          .toList();
                    } else if (filterState == 'Approved') {
                      filteredData = snapshot.data!
                          .where(
                            (cutting) =>
                                cutting.workflowState == 'Approved' ||
                                cutting.workflowState == 'Authorized',
                          )
                          .toList();
                    } else if (filterState == 'Rejected') {
                      filteredData = snapshot.data!
                          .where(
                            (cutting) => cutting.workflowState == 'Rejected',
                          )
                          .toList();
                    }
                    return Expanded(
                      child: ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          Datum cuttings = filteredData[index];

                          return Padding(
                            padding: EdgeInsets.all(8.0.w),
                            child: Card(
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(PdfViewerPage(name: cuttings.name!));
                                },
                                child: Container(
                                  height: height / 4.55.h,
                                  width: width / 1.3.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 10.h),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: ScreenUtil().setWidth(20.0),
                                            ),
                                            child: Text(
                                              cuttings.name.toString(),
                                              style: GoogleFonts.openSans(
                                                textStyle: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.blueGrey,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                right: ScreenUtil().setWidth(
                                                  20.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Red dot for "Pending"
                                                  if (cuttings.workflowState
                                                          .toString() ==
                                                      'Pending')
                                                    Container(
                                                      width: 8.w,
                                                      height: 8.h,
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  SizedBox(width: 4.w),
                                                  Text(
                                                    cuttings.workflowState
                                                        .toString(),
                                                    style: GoogleFonts.openSans(
                                                      textStyle: TextStyle(
                                                        fontSize: 15.sp,
                                                        color:
                                                            _getBackgroundColor(
                                                          cuttings.workflowState
                                                              .toString(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.h),
                                      SizedBox(height: 2.h),
                                      buildDataRow(
                                        "SubContractor",
                                        cuttings.subcon.toString(),
                                      ),
                                      SizedBox(height: 2.h),
                                      buildDataRow(
                                        "Work Order",
                                        cuttings.workOrdNo.toString(),
                                      ),
                                      SizedBox(height: 2.h),
                                      buildDataRow(
                                        "Fabric Issues",
                                        cuttings.fiNo.toString(),
                                      ),
                                      SizedBox(height: 10.h),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDataRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(15.0)),
            child: Text(
              label,
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  fontSize: 13.4.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: ScreenUtil().setWidth(15.0)),
            child: Text(
              value,
              style: GoogleFonts.openSans(
                textStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Filter by Cutting Inward',
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('All'),
                value: 'All',
                groupValue: filterState,
                onChanged: (value) {
                  setState(() {
                    filterState = value!;
                    Navigator.pop(context);
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Pending'),
                value: 'Pending',
                groupValue: filterState,
                onChanged: (value) {
                  setState(() {
                    filterState = value!;
                    Navigator.pop(context);
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Approved'),
                value: 'Approved',
                groupValue: filterState,
                onChanged: (value) {
                  setState(() {
                    filterState = value!;
                    Navigator.pop(context);
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Rejected'),
                value: 'Rejected',
                groupValue: filterState,
                onChanged: (value) {
                  setState(() {
                    filterState = value!;
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

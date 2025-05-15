import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:zee/view/screens/home.dart';
import 'package:zee/view/screens/pdf_order.dart';
import 'package:zee/view/widgets/text.dart';

import '../../model/json_model/order_json.dart';
import '../../services/order_api.dart';
import '../widgets/subhead.dart';

class OrderForm extends StatefulWidget {
  final String updatedWorkflowState;
  const OrderForm({super.key, required this.updatedWorkflowState});

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  late double height;
  late double width;
  String actionData = '';
  String actionTake = '';
  int pendingCount = 0;
  String filterState = 'Pending'; // Filter state

  Future<void> workflow_update() async {
    HttpClient client = HttpClient();
    client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    IOClient ioClient = IOClient(client);

    final url = Uri.parse(
      'https://zeemax.regenterp.com/api/resource/Order%20Form?fields=[%22name%22,"workflow_state"]&limit_page_length=50000',
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
        }
        if (kDebugMode) {
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
      case 'Authorize':
        return Colors.brown;
      case 'Pending':
        return Colors.red.shade600;
      default:
        return Colors.grey;
    }
  }

  void actionAlerts(context) {
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
      desc: "Select the Action",
      buttons: [
        DialogButton(
          color: Colors.grey.shade200,
          onPressed: () {
            setState(() {
              if (actionData == 'Initiated') {
                actionTake = "Approved";
              } else {
                actionTake = "Authorize";
              }
            });
            workflow_update(); // Call the workflow_update after setting actionTake
            Get.back(); // Close the alert after selecting action
          },
          child: MyTextOne(
            text: (actionData == 'Initiated') ? "Approved" : "Authorize",
            color: Colors.blue,
          ),
        ),
        DialogButton(
          color: Colors.grey.shade200,
          onPressed: () {
            Get.back(); // Close the alert if "Rejected" is selected
          },
          child: const MyTextOne(text: "Rejected", color: Colors.red),
        ),
      ],
    ).show();
  }

  /// WillPopscope //
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
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        height = constraints.maxHeight;
        width = constraints.maxWidth;
        if (width <= 450) {
          return _smallBuildLayout();
        } else {
          return const Text("Please make sure your device is in portrait view");
        }
      },
    );
  }

  Widget _smallBuildLayout() {
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
          title: const Subhead(text: " Order Form", color: Colors.white),
          backgroundColor: Colors.red.shade700,
          centerTitle: true,
        ),
        body: SizedBox(
          width: width.w,
          child: Column(
            children: [
              SizedBox(height: 10.h),
              FutureBuilder<List<Datumord>>(
                future: fetchOrder(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  } else {
                    pendingCount =
                        snapshot.data!
                            .where((order) => order.workflowState == 'Pending')
                            .length;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 58.0),
                          child: Text(
                            filterState == 'Pending'
                                ? "Pending: $pendingCount"
                                : "Filter: $filterState",
                            style: GoogleFonts.dmSans(
                              textStyle: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 80.0),
                          child: IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed:
                                _showFilterDialog, // Open filter dialog on button press
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              FutureBuilder<List<Datumord>>(
                future: fetchOrder(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  } else {
                    var filteredData = snapshot.data!;
                    if (filterState != 'All') {
                      filteredData =
                          snapshot.data!.where((order) {
                            if (filterState == 'Pending') {
                              return order.workflowState == 'Pending';
                            } else if (filterState == 'Approved') {
                              return order.workflowState == 'Approved';
                            } else if (filterState == 'Authorize') {
                              return order.workflowState == 'Authorize';
                            } else if (filterState == 'Rejected') {
                              return order.workflowState == 'Rejected';
                            }
                            return true;
                          }).toList();
                    }

                    return Expanded(
                      child: ListView.builder(
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          Datumord orders = filteredData[index];

                          return Padding(
                            padding: EdgeInsets.all(8.0.w),
                            child: Card(
                              child: GestureDetector(
                                onTap: () {
                                  Get.to(Pdforder(name: orders.name!));
                                },
                                child: Container(
                                  height: height / 4.16.h,
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
                                              orders.name.toString(),
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
                                              child: buildWorkflowStatus(
                                                orders.workflowState.toString(),
                                                index + 1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5.h),
                                      SizedBox(height: 2.h),
                                      buildDataRow(
                                        "Company",
                                        orders.company.toString(),
                                      ),
                                      SizedBox(height: 2.h),
                                      buildDataRow(
                                        "Date",
                                        orders.date.toString(),
                                      ),
                                      SizedBox(height: 2.h),
                                      buildDataRow(
                                        "Buyer",
                                        orders.buyer.toString(),
                                      ),
                                      SizedBox(height: 2.h),
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

  Widget buildWorkflowStatus(String workflowState, int pendingCount) {
    Widget redDot = Container(
      width: 7.w,
      height: 10.w,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );

    String displayText = workflowState;

    return Row(
      children: [
        if (workflowState == 'Pending') redDot,
        SizedBox(width: 5.w),
        Text(
          displayText,
          style: GoogleFonts.openSans(
            textStyle: TextStyle(
              fontSize: 15.sp,
              color: _getBackgroundColor(workflowState),
            ),
          ),
        ),
      ],
    );
  }

  // Filter Dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Filter Orders',
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
                  });
                  Get.back(); // Close the dialog
                },
              ),
              RadioListTile<String>(
                title: const Text('Pending'),
                value: 'Pending',
                groupValue: filterState,
                onChanged: (value) {
                  setState(() {
                    filterState = value!;
                  });
                  Get.back();
                },
              ),
              RadioListTile<String>(
                title: const Text('Approved'),
                value: 'Approved',
                groupValue: filterState,
                onChanged: (value) {
                  setState(() {
                    filterState = value!;
                  });
                  Get.back();
                },
              ),
              RadioListTile<String>(
                title: const Text('Authorized'),
                value: 'Authorize',
                groupValue: filterState,
                onChanged: (value) {
                  setState(() {
                    filterState = value!;
                  });
                  Get.back();
                },
              ),
              RadioListTile<String>(
                title: const Text('Rejected'),
                value: 'Rejected',
                groupValue: filterState,
                onChanged: (value) {
                  setState(() {
                    filterState = value!;
                  });
                  Get.back();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

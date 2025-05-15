import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:zee/view/screens/Box_stock.dart';
import 'package:zee/view/screens/Sale_order_pending_report.dart';
import 'package:zee/view/screens/cutting_inward.dart';
import 'package:zee/view/screens/order.dart';
import 'package:zee/view/screens/po.dart';
import 'package:zee/view/widgets/heading.dart';
import 'package:zee/view/widgets/text.dart';

import '../widgets/subhead.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late double height;
  late double width;

  // Variables for pending counts
  int cuttingPendingCount = 0; // Pending count for Cutting
  int orderPendingCount = 0; // Pending count for Order
  int poPendingCount = 0; // Pending count for PO

  @override
  void initState() {
    super.initState();
    _fetchPendingOrderCount(); // Fetch pending order count when the page is loaded
    _fetchPendingCuttingCount(); // Fetch pending cutting count when the page is loaded
    _fetchPendingPOCount(); // Fetch pending Po  count when the page is loaded
  }

  /// Fetch pending orders from API //
  Future<void> _fetchPendingOrderCount() async {
    try {
      var url = Uri.parse(
        'https://zeemax.regenterp.com/api/resource/Order%20Form?fields=["name","company","date","buyer","due_date","order_no","workflow_state","consignee","priority","product","all_size"]&limit_page_length=50000',
      );

      var headers = {"Authorization": "token ed4bbea42d574b6:11d2aaabc1967e0"};

      // Fetch data from the API
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Decode the response
        var jsonResponse = jsonDecode(response.body);

        // Filter orders with "Pending" status in workflow_state
        var pendingOrders =
            jsonResponse['data']
                .where(
                  (order) =>
                      order['workflow_state'] == "Pending" ||
                      order['workflow_state'] == "Initiated",
                )
                .toList();

        // Update the pending count for orders
        setState(() {
          orderPendingCount = pendingOrders.length;
        });
      } else {
        print("Failed to fetch orders");
      }
    } catch (e) {
      print("Error fetching order data: $e");
    }
  }

  /// Fetch pending cutting inward from API //
  Future<void> _fetchPendingCuttingCount() async {
    try {
      var url = Uri.parse(
        'https://zeemax.regenterp.com/api/resource/Cutting%20Inward?fields=[%22name%22,%22subcon%22,%22process_name%22,%22work_ord_no%22,%22date%22,%22fi_no%22,%22workflow_state%22,%22employee%22,%22warehouse%22]&limit_page_length=50000',
      );

      var headers = {"Authorization": "token ed4bbea42d574b6:11d2aaabc1967e0"};

      // Fetch data from the API
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Decode the response
        var jsonResponse = jsonDecode(response.body);

        // Filter Cutting Inward records with "Pending" status in workflow_state
        var pendingCuttingInwards =
            jsonResponse['data']
                .where(
                  (cutting) =>
                      cutting['workflow_state'] == "Pending" ||
                      cutting['workflow_state'] == "Initiated",
                )
                .toList();

        // Update the pending count for Cutting Inward
        setState(() {
          cuttingPendingCount = pendingCuttingInwards.length;
        });
        print(response.body);
        print(response.statusCode);
      } else {
        print("Failed to fetch Cutting Inward");
      }
    } catch (e) {
      print("Error fetching Cutting Inward data: $e");
    }
  }

  /// Fetch Po Api's  method //

  Future<void> _fetchPendingPOCount() async {
    try {
      // API URL for PO resource
      var url = Uri.parse(
        'https://zeemax.regenterp.com/api/resource/PO?fields=["name","company","supplier","type","order_type","due_date","work_ord_no","workflow_state"]&limit_page_length=50000',
      );

      var headers = {"Authorization": "token ed4bbea42d574b6:11d2aaabc1967e0"};

      // Fetch data from the API
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // Decode the response
        var jsonResponse = jsonDecode(response.body);

        // Filter PO records with "Pending" or "Initiated" status in workflow_state
        var pendingPOs =
            jsonResponse['data']
                .where(
                  (po) =>
                      po['workflow_state'] == "Pending" ||
                      po['workflow_state'] == "Initiated",
                )
                .toList();

        // Update the pending count for PO
        setState(() {
          poPendingCount = pendingPOs.length;
        });
        print(response.body);
        print(response.statusCode);
      } else {
        print("Failed to fetch PO data");
      }
    } catch (e) {
      print("Error fetching PO data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Define Sizes //
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
          return const Text("Please Make Sure Your Device is in Portrait view");
        }
      },
    );
  }

  Widget _smallBuildLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Subhead(text: "Dashboard", color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.red.shade700,
      ),
      body: SizedBox(
        width: width.w,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: height / 2.5.h,
                width: width / 1.w,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/home.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.to(const CuttingInward(updateWorkflowState: ''));
                },
                child: Container(
                  height: height / 4.7.h,
                  width: width / 1.w,
                  decoration: BoxDecoration(
                    color: Colors.brown.shade400,
                    borderRadius: BorderRadius.circular(26.r),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 7.h),
                      // const  Icon(Icons.cut,color: Colors.red,size: 20,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Subhead(
                                text: "CUTTING INWARD",
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Container(
                                width: width / 7.w,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  shape: BoxShape.circle,
                                ),
                                child: Transform.rotate(
                                  angle: 60 * math.pi / 180,
                                  child: IconButton(
                                    onPressed: () {
                                      Get.to(
                                        const CuttingInward(
                                          updateWorkflowState: '',
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.arrow_upward,
                                      size: 23,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      // Display the pending count for Cutting Inward from the API
                      Padding(
                        padding: EdgeInsets.only(
                          right: ScreenUtil().setWidth(210.0),
                        ),
                        child: Headingtext(
                          text: '$cuttingPendingCount',
                          color: Colors.white,
                          weight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: EdgeInsets.only(
                          right: ScreenUtil().setWidth(210.0),
                        ),
                        child: const MyTextOne(
                          text: " Pending",
                          color: Colors.white,
                        ),
                        // GestureDetector(
                        //   onTap: (){
                        //     Get.to(const OrderForm(updatedWorkflowState: ''));
                        //   },
                        //   child: Container(
                        //     height: height/12.h,
                        //     width: width/1.1.w,
                        //     decoration: BoxDecoration(
                        //         color: Colors.white,
                        //         borderRadius: BorderRadius.circular(5.r)
                        //     ),
                        //     child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         SizedBox(height: 10.h,),
                        //         Padding(
                        //           padding:  EdgeInsets.only(right: ScreenUtil().setWidth(8.0)),
                        //           child: const Icon(Icons.delivery_dining,color: Colors.red,size: 23,),
                        //         ),
                        //         const Divider(),
                        //         const MyTextOne(text: "ORDER", color: Colors.red),
                        //         const Divider(),
                        //         // Display the pending count for Cutting Inward from the API
                        //         Padding(
                        //           padding:  EdgeInsets.only(right: ScreenUtil().setWidth(8.0)),
                        //           child: MyTextOne(
                        //             text: "  Pending : $orderPendingCount ",
                        //             color: Colors.black,
                        //           ),
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: 10.h,),
                        // GestureDetector(
                        //   onTap: (){
                        //     Get.to(const POScreen(updateWorkflowState: ''));
                        //   },
                        //   child: Container(
                        //     height: height/12.h,
                        //     width: width/1.1.w,
                        //     decoration: BoxDecoration(
                        //         color: Colors.white,
                        //         borderRadius: BorderRadius.circular(5.r)
                        //     ),
                        //     child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         SizedBox(height: 10.h,),
                        //         Padding(
                        //           padding:  EdgeInsets.only(right: ScreenUtil().setWidth(8.0)),
                        //           child: const Icon(Icons.production_quantity_limits_outlined,color: Colors.red,size: 23,),
                        //         ),
                        //         const Divider(),
                        //         const MyTextOne(text: "PO", color: Colors.red),
                        //         const Divider(),
                        //         // Display the pending count for Cutting Inward from the API
                        //         Padding(
                        //           padding:  EdgeInsets.only(right: ScreenUtil().setWidth(8.0)),
                        //           child: MyTextOne(
                        //             text: "  Pending : $poPendingCount ",
                        //             color: Colors.black,
                        //           ),
                        //         )
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ),
                    ],
                  ),
                ),
              ),
              // SizedBox(width: 30.w,),
              Padding(
                padding: const EdgeInsets.only(
                  left: 11.0,
                  top: 2.0,
                  right: 11.0,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(const OrderForm(updatedWorkflowState: ''));
                      },
                      child: Container(
                        height: height / 4.h,
                        width: width / 2.w,
                        decoration: BoxDecoration(
                          color: Colors.pink.shade100,
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 10.h),
                            // const  Icon(Icons.cut,color: Colors.red,size: 20,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: Subhead(
                                      text: "ORDER",
                                      color: Colors.black,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: Container(
                                      width: width / 7.w,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Transform.rotate(
                                        angle: 60 * math.pi / 180,
                                        child: IconButton(
                                          onPressed: () {
                                            Get.to(
                                              const OrderForm(
                                                updatedWorkflowState: '',
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.arrow_upward,
                                            size: 23,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                            // Display the pending count for Cutting Inward from the API
                            Padding(
                              padding: const EdgeInsets.only(right: 90.0),
                              child: Headingtext(
                                text: '$orderPendingCount',
                                color: Colors.black,
                                weight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Padding(
                              padding: EdgeInsets.only(right: 70.0),
                              child: MyTextOne(
                                text: " Pending",
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: () {
                        Get.to(const POScreen(updateWorkflowState: ''));
                      },
                      child: Container(
                        height: height / 4.h,
                        width: width / 2.w,
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade100,
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 10.h),
                            // const  Icon(Icons.cut,color: Colors.red,size: 20,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: Subhead(
                                      text: "PO",
                                      color: Colors.black,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: Container(
                                      width: width / 7.w,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Transform.rotate(
                                        angle: 60 * math.pi / 180,
                                        child: IconButton(
                                          onPressed: () {
                                            Get.to(
                                              const POScreen(
                                                updateWorkflowState: '',
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.arrow_upward,
                                            size: 23,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                            // Display the pending count for Cutting Inward from the API
                            Padding(
                              padding: const EdgeInsets.only(right: 90.0),
                              child: Headingtext(
                                text: '$poPendingCount',
                                color: Colors.black,
                                weight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Padding(
                              padding: EdgeInsets.only(right: 70.0),
                              child: MyTextOne(
                                text: " Pending",
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 11.0,
                  top: 2.0,
                  right: 11.0,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(const BoxStock());
                      },
                      child: Container(
                        height: height / 4.h,
                        width: width / 2.w,
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent.shade100,
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 10.h),
                            // const  Icon(Icons.cut,color: Colors.red,size: 20,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: Subhead(
                                      text: "Box Stock",
                                      color: Colors.black,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: Container(
                                      width: width / 7.w,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Transform.rotate(
                                        angle: 60 * math.pi / 180,
                                        child: IconButton(
                                          onPressed: () {
                                            Get.to(const BoxStock());
                                          },
                                          icon: const Icon(
                                            Icons.arrow_upward,
                                            size: 23,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                            // Display the pending count for Cutting Inward from the API
                            const Padding(
                              padding: EdgeInsets.only(right: 90.0),
                              child: Icon(Icons.note_alt_sharp),
                            ),
                            const SizedBox(height: 2),
                            const Padding(
                              padding: EdgeInsets.only(right: 70.0),
                              child: MyTextOne(
                                text: "Reports",
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: () {
                        Get.to(const SalesOrderPendingReport());
                      },
                      child: Container(
                        height: height / 4.h,
                        width: width / 2.w,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 10.h),
                            // const  Icon(Icons.cut,color: Colors.red,size: 20,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: Subhead(
                                      text: "Sale Order",
                                      color: Colors.black,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: Container(
                                      width: width / 7.w,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Transform.rotate(
                                        angle: 60 * math.pi / 180,
                                        child: IconButton(
                                          onPressed: () {
                                            Get.to(
                                              const SalesOrderPendingReport(),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.arrow_upward,
                                            size: 23,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                            // Display the pending count for Cutting Inward from the API
                            const Padding(
                              padding: EdgeInsets.only(right: 90.0),
                              child: Icon(Icons.note_alt_sharp),
                            ),
                            const SizedBox(height: 2),
                            const Padding(
                              padding: EdgeInsets.only(right: 70.0),
                              child: MyTextOne(
                                text: " Reports",
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

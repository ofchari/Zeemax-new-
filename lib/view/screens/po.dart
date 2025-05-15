import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../model/json_model/po_json.dart';
import '../../services/po_api.dart';
import '../widgets/subhead.dart';
import 'home.dart';
import 'pdf_po.dart';

class POScreen extends StatefulWidget {
  final String updateWorkflowState;
  const POScreen({super.key, required this.updateWorkflowState});

  @override
  State<POScreen> createState() => _POScreenState();
}

class _POScreenState extends State<POScreen> {
  late double height;
  late double width;
  int pendingCount = 0;
  String filterState = 'Pending'; // Default to 'Pending'

  // Cache the future to avoid multiple API calls
  late Future<List<Datumpo>> _poFuture;

  @override
  void initState() {
    super.initState();
    _poFuture = fetchPo();
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
                  Get.offAll(() => const Home());
                },
                child: const Text("Yes", style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade500,
                ),
                onPressed: () {
                  Navigator.pop(context);
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
          title: const Subhead(text: " PO Screen", color: Colors.white),
          backgroundColor: Colors.red.shade700,
          centerTitle: true,
        ),
        body: SizedBox(
          width: width.w,
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0.h),
                child: FutureBuilder<List<Datumpo>>(
                  future: _poFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("No PO data found");
                    } else {
                      pendingCount =
                          snapshot.data!
                              .where((po) => po.workflowState == 'Pending')
                              .length;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 58.0),
                            child: Text(
                              filterState == 'Pending'
                                  ? "Pending Count: $pendingCount"
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
                          SizedBox(width: 10.w),
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
              FutureBuilder<List<Datumpo>>(
                future: _poFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No PO data found"));
                  } else {
                    List<Datumpo> filteredData = snapshot.data!;

                    if (filterState == 'Pending') {
                      filteredData =
                          snapshot.data!
                              .where((po) => po.workflowState == 'Pending')
                              .toList();
                    } else if (filterState == 'Approved') {
                      filteredData =
                          snapshot.data!
                              .where(
                                (po) =>
                                    po.workflowState == 'Approved' ||
                                    po.workflowState == 'Authorized',
                              )
                              .toList();
                    } else if (filterState == 'Rejected') {
                      filteredData =
                          snapshot.data!
                              .where((po) => po.workflowState == 'Rejected')
                              .toList();
                    }

                    return Expanded(
                      child:
                          filteredData.isEmpty
                              ? const Center(
                                child: Text("No POs match the selected filter"),
                              )
                              : ListView.builder(
                                itemCount: filteredData.length,
                                itemBuilder: (context, index) {
                                  Datumpo po = filteredData[index];
                                  return _buildPOCard(po);
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

  Widget _buildPOCard(Datumpo po) {
    return Padding(
      padding: EdgeInsets.all(8.0.w),
      child: Card(
        child: GestureDetector(
          onTap: () {
            if (po.name != null && po.type != null) {
              Get.to(PdfPoView(name: po.name!, type: po.type!));
            }
          },
          child: Container(
            height: height / 4.55.h,
            width: width / 1.3.w,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(20.0),
                      ),
                      child: Text(
                        po.name?.toString() ?? "No name",
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
                          right: ScreenUtil().setWidth(20.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (po.workflowState == 'Pending')
                              Container(
                                width: 8.w,
                                height: 8.h,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            SizedBox(width: 4.w),
                            Text(
                              po.workflowState?.toString() ?? "Unknown",
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  fontSize: 15.sp,
                                  color: _getBackgroundColor(
                                    po.workflowState?.toString() ?? "",
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
                  "Supplier",
                  po.supplier?.toString() ?? "Not specified",
                ),
                SizedBox(height: 2.h),
                buildDataRow("Type", po.type?.toString() ?? "Not specified"),
                SizedBox(height: 2.h),
                buildDataRow(
                  "Order Number",
                  po.workOrdNo?.toString() ?? "Not specified",
                ),
                SizedBox(height: 10.h),
              ],
            ),
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
            'Filter by PO Workflow',
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

  // Refresh PO data
  void refreshData() {
    setState(() {
      _poFuture = fetchPo();
    });
  }
}

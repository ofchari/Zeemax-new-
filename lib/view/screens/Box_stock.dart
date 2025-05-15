import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../widgets/subhead.dart';
import 'home.dart';

class BoxStock extends StatefulWidget {
  const BoxStock({super.key});

  @override
  State<BoxStock> createState() => _BoxStockState();
}

class _BoxStockState extends State<BoxStock> {
  List<Map<String, dynamic>> stockData = [];
  List<Map<String, dynamic>> filteredData = [];
  bool isLoading = true;

  // Filter controllers
  final TextEditingController nameFilterController = TextEditingController();
  final TextEditingController itemGroupFilterController =
      TextEditingController();

  // Predefined order for size columns
  final List<String> sizeOrder = [
    'xs',
    's',
    'm',
    'l',
    'xl',
    '2xl',
    '3xl',
    '4xl',
    '5xl',
    '6xl',
    'xxs',
    'xs',
    'small',
    'medium',
    'large',
    'xl',
    'xxl',
    'xxxl',
    '4xxl',
    '5xxl'
  ];

  /// Back press confirmation dialog
  Future<bool> popScopes(BuildContext context) async {
    return await Get.dialog(
          AlertDialog(
            title: const Text("Are you sure you want to exit?"),
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
                    backgroundColor: Colors.red.shade500),
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
  void initState() {
    super.initState();
    fetchStockData();
  }

  @override
  void dispose() {
    nameFilterController.dispose();
    itemGroupFilterController.dispose();
    super.dispose();
  }

  // Apply filters to the data
  void applyFilters() {
    setState(() {
      final nameFilter = nameFilterController.text.toLowerCase();
      final itemGroupFilter = itemGroupFilterController.text.toLowerCase();

      filteredData = stockData.where((item) {
        final nameMatch = nameFilter.isEmpty ||
            (item['name'] != null &&
                item['name'].toString().toLowerCase().contains(nameFilter));
        final itemGroupMatch = itemGroupFilter.isEmpty ||
            (item['item_group'] != null &&
                item['item_group']
                    .toString()
                    .toLowerCase()
                    .contains(itemGroupFilter));

        return nameMatch && itemGroupMatch;
      }).toList();
    });
  }

  Future<void> fetchStockData() async {
    final url =
        'https://zeemax.regenterp.com/api/method/frappe.desk.query_report.run?report_name=Box%20Stock%20Size%20Report&filters=%7B%22item_group%22%3A%5B%5D%2C%22product%22%3A%5B%5D%7D';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'token ed4bbea42d574b6:11d2aaabc1967e0',
        },
      );

      debugPrint(response.statusCode.toString());

      if (response.statusCode == 200) {
        // First, decode the JSON response
        final dynamic decodedJson = jsonDecode(response.body);

        // Now, explicitly check the expected structure without any assumptions
        if (decodedJson is Map) {
          // Only proceed if decodedJson is a Map
          final dynamic message = decodedJson['message'];

          if (message != null) {
            // Check if message contains result
            if (message is Map && message.containsKey('result')) {
              final dynamic result = message['result'];

              if (result is List) {
                setState(() {
                  // Convert each item to a Map<String, dynamic> safely
                  stockData = [];
                  for (var item in result) {
                    if (item is Map) {
                      stockData.add(Map<String, dynamic>.from(item));
                    }
                  }
                  // Initialize filtered data with all data
                  filteredData = List.from(stockData);
                  isLoading = false;
                });
              } else {
                setState(() {
                  stockData = [];
                  filteredData = [];
                  isLoading = false;
                });
                debugPrint('Result is not a List: ${result.runtimeType}');
              }
            } else if (message is List) {
              setState(() {
                // Handle when message itself is a List
                stockData = [];
                for (var item in message) {
                  if (item is Map) {
                    stockData.add(Map<String, dynamic>.from(item));
                  }
                }
                // Initialize filtered data with all data
                filteredData = List.from(stockData);
                isLoading = false;
              });
            } else {
              setState(() {
                stockData = [];
                filteredData = [];
                isLoading = false;
              });
              debugPrint(
                  'Message is not in expected format: ${message.runtimeType}');
            }
          } else {
            setState(() {
              stockData = [];
              filteredData = [];
              isLoading = false;
            });
            debugPrint('Message is null');
          }
        } else {
          setState(() {
            stockData = [];
            filteredData = [];
            isLoading = false;
          });
          debugPrint('Decoded JSON is not a Map: ${decodedJson.runtimeType}');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        debugPrint('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching stock data: $e');

      // Print the full body of the response to help diagnose the issue
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'token ed4bbea42d574b6:11d2aaabc1967e0',
          },
        );
        debugPrint('Response body: ${response.body}');
      } catch (e) {
        debugPrint('Could not print response body: $e');
      }
    }
  }

  /// Collect all size keys and sort them in a logical order (S, M, L, XL, etc.)
  List<String> getSizeColumns() {
    final Set<String> sizeKeys = {};

    // Standard fields to exclude
    final standardFields = ["name", "item_group", "style", "total", "value"];

    // Collect all non-standard keys that might be size columns
    for (var item in stockData) {
      item.forEach((key, value) {
        if (!standardFields.contains(key) && value != 0) {
          sizeKeys.add(key);
        }
      });
    }

    // Convert to list for sorting
    final List<String> sizeList = sizeKeys.toList();

    // Sort the size columns in a natural order (S, M, L, XL, 2XL, etc.)
    sizeList.sort((a, b) {
      // Convert keys to lowercase for comparison
      String aLower = a.toLowerCase();
      String bLower = b.toLowerCase();

      // Check if both keys are in the predefined order
      int aIndex = sizeOrder.indexOf(aLower);
      int bIndex = sizeOrder.indexOf(bLower);

      // If both are in the predefined list, sort by that order
      if (aIndex != -1 && bIndex != -1) {
        return aIndex.compareTo(bIndex);
      }
      // If only one is in the list, prefer the predefined one
      else if (aIndex != -1) {
        return -1;
      } else if (bIndex != -1) {
        return 1;
      }

      // Handle numeric sizes (like "28", "30", "32")
      bool aIsNumeric = double.tryParse(a) != null;
      bool bIsNumeric = double.tryParse(b) != null;

      if (aIsNumeric && bIsNumeric) {
        return double.parse(a).compareTo(double.parse(b));
      } else if (aIsNumeric) {
        return -1; // Numbers come before text
      } else if (bIsNumeric) {
        return 1; // Numbers come before text
      }

      // For sizes with numerical prefixes like "2XL", "3XL"
      RegExp sizeRegex = RegExp(r'^(\d*)([a-zA-Z]+)$');
      Match? aMatch = sizeRegex.firstMatch(aLower);
      Match? bMatch = sizeRegex.firstMatch(bLower);

      if (aMatch != null && bMatch != null) {
        String aLetterPart = aMatch.group(2) ?? '';
        String bLetterPart = bMatch.group(2) ?? '';

        // If letter parts are the same (like "XL" in "2XL" and "3XL")
        if (aLetterPart == bLetterPart) {
          // Compare the number parts
          String aNumPart = aMatch.group(1) ?? '';
          String bNumPart = bMatch.group(1) ?? '';

          // Handle empty number (e.g., "XL" vs "2XL")
          if (aNumPart.isEmpty) return -1;
          if (bNumPart.isEmpty) return 1;

          return int.parse(aNumPart).compareTo(int.parse(bNumPart));
        }
      }

      // Default alphabetical comparison
      return aLower.compareTo(bLower);
    });

    return sizeList;
  }

  @override
  Widget build(BuildContext context) {
    final sizeColumns = getSizeColumns();

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
          title: const Subhead(text: "Box Stock Report", color: Colors.white),
          backgroundColor: Colors.red.shade700,
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : stockData.isEmpty
                ? const Center(child: Text('No data available'))
                : Column(
                    children: [
                      // Filters section
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: nameFilterController,
                                decoration: const InputDecoration(
                                  labelText: 'Filter by Name',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                ),
                                onChanged: (_) => applyFilters(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: itemGroupFilterController,
                                decoration: const InputDecoration(
                                  labelText: 'Filter by Item Group',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                ),
                                onChanged: (_) => applyFilters(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                nameFilterController.clear();
                                itemGroupFilterController.clear();
                                applyFilters();
                              },
                              tooltip: 'Clear filters',
                            ),
                          ],
                        ),
                      ),
                      // Data table section
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              columnSpacing: 14,
                              columns: [
                                DataColumn(
                                    label: Text(
                                  'Name',
                                  style: GoogleFonts.dmSans(
                                      textStyle: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black)),
                                )),
                                DataColumn(
                                    label: Text('Item Group',
                                        style: GoogleFonts.dmSans(
                                            textStyle: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black)))),
                                ...sizeColumns.map((size) => DataColumn(
                                    label: Text(size.toUpperCase(),
                                        style: GoogleFonts.dmSans(
                                            textStyle: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black))))),
                                DataColumn(
                                    label: Text('Total',
                                        style: GoogleFonts.dmSans(
                                            textStyle: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black)))),
                                DataColumn(
                                    label: Text('Value',
                                        style: GoogleFonts.dmSans(
                                            textStyle: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black)))),
                              ],
                              rows: filteredData.map((item) {
                                return DataRow(cells: [
                                  DataCell(Text(item['name'] ?? '',
                                      style: GoogleFonts.dmSans(
                                          textStyle: TextStyle(
                                              fontSize: 13.5.sp,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black)))),
                                  DataCell(Text(item['item_group'] ?? '',
                                      style: GoogleFonts.dmSans(
                                          textStyle: TextStyle(
                                              fontSize: 13.5.sp,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black)))),
                                  ...sizeColumns.map((key) => DataCell(Text(
                                      item[key]?.toString() ?? '0',
                                      style: GoogleFonts.dmSans(
                                          textStyle: TextStyle(
                                              fontSize: 13.5.sp,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black))))),
                                  DataCell(Text(
                                      item['total']?.toString() ?? '0',
                                      style: GoogleFonts.dmSans(
                                          textStyle: TextStyle(
                                              fontSize: 13.5.sp,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black)))),
                                  DataCell(Text('₹${item['value'] ?? 0}',
                                      style: GoogleFonts.dmSans(
                                          textStyle: TextStyle(
                                              fontSize: 13.5.sp,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black)))),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

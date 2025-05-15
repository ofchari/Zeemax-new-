import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTextOne extends StatefulWidget {
  const MyTextOne({super.key,required this.text,required this.color});
  final String text;
  // final FontWeight weight;
  final Color color;

  @override
  State<MyTextOne> createState() => _MyTextOneState();
}

class _MyTextOneState extends State<MyTextOne> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.text,style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 14.sp,fontWeight: FontWeight.w500,color: widget.color)),);
  }
}

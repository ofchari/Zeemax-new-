import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class Buttons extends StatefulWidget {
  const Buttons({super.key,required this.heigh,required this.width,required this.color,required this.text,required this.radius});
  final double heigh;
  final double width;
  final Color color;
  final String text;
  final BorderRadius radius;

  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.heigh,
      width: widget.width,
      decoration: BoxDecoration(
          borderRadius: widget.radius,
          color: widget.color
      ),
      child: Center(child: Text(widget.text,style: GoogleFonts.dmSans(textStyle: TextStyle(fontSize: 13.5.sp,fontWeight: FontWeight.w500,color: Colors.white)),)),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'cutting_inward.dart';
// import 'order.dart';
//
// class BottomNavigation extends StatefulWidget {
//   const BottomNavigation({super.key});
//
//   @override
//   State<BottomNavigation> createState() => _BottomNavigationState();
// }
//
// class _BottomNavigationState extends State<BottomNavigation> {
//   int currentindex = 0;
//
//   final pages = [
//     const CuttingInward(updateWorkflowState: '',),
//     const OrderForm(updatedWorkflowState: '',)
//   ];
//
//   void krish(int index){
//     setState(() {
//       currentindex = index;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: pages[currentindex],
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(
//               icon: Icon(Icons.cut),
//               label: "Cutting"
//           ),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.delivery_dining),
//               label: "Order"
//           ),
//         ],
//         onTap: krish,
//         currentIndex: currentindex,
//       ),
//
//     );
//   }
// }

// class Saleorderpending {
//   Saleorderpending({
//     required this.message,
//   });
//
//   final Message? message;
//
//   factory Saleorderpending.fromJson(Map<String, dynamic> json){
//     return Saleorderpending(
//       message: json["message"] == null ? null : Message.fromJson(json["message"]),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     "message": message?.toJson(),
//   };
//
// }
//
// class Message {
//   Message({
//     required this.result,
//     required this.columns,
//     required this.message,
//     required this.chart,
//     required this.reportSummary,
//     required this.skipTotalRow,
//     required this.status,
//     required this.executionTime,
//     required this.addTotalRow,
//   });
//
//   final List<dynamic> result;
//   final List<Column> columns;
//   final dynamic message;
//   final dynamic chart;
//   final dynamic reportSummary;
//   final int? skipTotalRow;
//   final dynamic status;
//   final double? executionTime;
//   final bool? addTotalRow;
//
//   factory Message.fromJson(Map<String, dynamic> json){
//     return Message(
//       result: json["result"] == null ? [] : List<dynamic>.from(json["result"]!.map((x) => x)),
//       columns: json["columns"] == null ? [] : List<Column>.from(json["columns"]!.map((x) => Column.fromJson(x))),
//       message: json["message"],
//       chart: json["chart"],
//       reportSummary: json["report_summary"],
//       skipTotalRow: json["skip_total_row"],
//       status: json["status"],
//       executionTime: json["execution_time"],
//       addTotalRow: json["add_total_row"],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     "result": result.map((x) => x).toList(),
//     "columns": columns.map((x) => x?.toJson()).toList(),
//     "message": message,
//     "chart": chart,
//     "report_summary": reportSummary,
//     "skip_total_row": skipTotalRow,
//     "status": status,
//     "execution_time": executionTime,
//     "add_total_row": addTotalRow,
//   };
//
// }
//
// class Column {
//   Column({
//     required this.fieldtype,
//     required this.options,
//     required this.width,
//     required this.label,
//     required this.fieldname,
//   });
//
//   final String? fieldtype;
//   final String? options;
//   final String? width;
//   final String? label;
//   final String? fieldname;
//
//   factory Column.fromJson(Map<String, dynamic> json){
//     return Column(
//       fieldtype: json["fieldtype"],
//       options: json["options"],
//       width: json["width"],
//       label: json["label"],
//       fieldname: json["fieldname"],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     "fieldtype": fieldtype,
//     "options": options,
//     "width": width,
//     "label": label,
//     "fieldname": fieldname,
//   };
//
// }
//
// class ResultClass {
//   ResultClass({
//     required this.the75,
//     required this.the80,
//     required this.the85,
//     required this.the100,
//     required this.saleOrderNo,
//     required this.partyNo,
//     required this.date,
//     required this.days,
//     required this.party,
//     required this.status,
//     required this.item,
//     required this.style,
//     required this.totalQuantity,
//   });
//
//   final dynamic the75;
//   final dynamic the80;
//   final dynamic the85;
//   final dynamic the100;
//   final String? saleOrderNo;
//   final String? partyNo;
//   final String? date;
//   final dynamic days;
//   final String? party;
//   final String? status;
//   final String? item;
//   final String? style;
//   final dynamic totalQuantity;
//
//   factory ResultClass.fromJson(Map<String, dynamic> json){
//     return ResultClass(
//       the75: json["75"],
//       the80: json["80"],
//       the85: json["85"],
//       the100: json["100"],
//       saleOrderNo: json["sale_order_no"],
//       partyNo: json["party_no"],
//       date: json["date"],
//       days: json["days"],
//       party: json["party"],
//       status: json["status"],
//       item: json["item"],
//       style: json["style"],
//       totalQuantity: json["total_quantity"],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     "75": the75,
//     "80": the80,
//     "85": the85,
//     "100": the100,
//     "sale_order_no": saleOrderNo,
//     "party_no": partyNo,
//     "date": date,
//     "days": days,
//     "party": party,
//     "status": status,
//     "item": item,
//     "style": style,
//     "total_quantity": totalQuantity,
//   };
//
// }

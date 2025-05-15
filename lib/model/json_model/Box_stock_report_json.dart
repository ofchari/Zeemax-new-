
// Model classes

class Box {
  Box({
    required this.message,
  });

  final Message? message;

  factory Box.fromJson(Map<String, dynamic> json) {
    return Box(
      message: json["message"] == null ? null : Message.fromJson(json["message"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "message": message?.toJson(),
  };
}

class Message {
  Message({
    required this.result,
    required this.columns,
    required this.message,
    required this.chart,
    required this.reportSummary,
    required this.skipTotalRow,
    required this.status,
    required this.executionTime,
    required this.addTotalRow,
  });

  final List<ResultClass> result;  // List of ResultClass
  final List<Boxcolumn> columns;       // List of Column
  final dynamic message;
  final dynamic chart;
  final dynamic reportSummary;
  final int? skipTotalRow;
  final dynamic status;
  final double? executionTime;
  final bool? addTotalRow;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      result: (json["result"] as List<dynamic>)
          .whereType<Map<String, dynamic>>() // Filter out non-object entries
          .map((item) => ResultClass.fromJson(item))
          .toList(),
      columns: json["columns"] == null
          ? []
          : List<Boxcolumn>.from(json["columns"]!.map((x) => Boxcolumn.fromJson(x))),
      message: json["message"],
      chart: json["chart"],
      reportSummary: json["report_summary"],
      skipTotalRow: json["skip_total_row"],
      status: json["status"],
      executionTime: json["execution_time"],
      addTotalRow: json["add_total_row"],
    );
  }

  Map<String, dynamic> toJson() => {
    "result": result.map((x) => x.toJson()).toList(),
    "columns": columns.map((x) => x.toJson()).toList(),
    "message": message,
    "chart": chart,
    "report_summary": reportSummary,
    "skip_total_row": skipTotalRow,
    "status": status,
    "execution_time": executionTime,
    "add_total_row": addTotalRow,
  };
}

class ResultClass {
  ResultClass({
    required this.warehouse,
    required this.product,
    required this.size,
    required this.box,
  });

  final String? warehouse;
  final String? product;
  final String? size;
  final int? box;

  factory ResultClass.fromJson(Map<String, dynamic> json) {
    return ResultClass(
      warehouse: json["warehouse"],
      product: json["product"],
      size: json["size"],
      box: (json["box"] is double) ? (json["box"] as double).toInt() : json["box"] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    "warehouse": warehouse,
    "product": product,
    "size": size,
    "box": box,
  };
}

class Boxcolumn {
  Boxcolumn({
    required this.fieldtype,
    required this.width,
    required this.label,
    required this.fieldname,
  });

  final String? fieldtype;
  final String? width;
  final String? label;
  final String? fieldname;

  factory Boxcolumn.fromJson(Map<String, dynamic> json) {
    return Boxcolumn(
      fieldtype: json["fieldtype"],
      width: json["width"],
      label: json["label"],
      fieldname: json["fieldname"],
    );
  }

  Map<String, dynamic> toJson() => {
    "fieldtype": fieldtype,
    "width": width,
    "label": label,
    "fieldname": fieldname,
  };
}



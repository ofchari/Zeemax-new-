class Cutting {
  Cutting({
    required this.data,
  });

  final List<Datum> data;

  factory Cutting.fromJson(Map<String, dynamic> json){
    return Cutting(
      data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data.map((x) => x.toJson()).toList(),
  };

}

class Datum {
  Datum({
    required this.name,
    required this.subcon,
    required this.processName,
    required this.workOrdNo,
    required this.date,
    required this.fiNo,
    required this.workflowState,
    required this.employee,
    required this.warehouse,
  });

  final String? name;
  final String? subcon;
  final String? processName;
  final String? workOrdNo;
  final DateTime? date;
  final String? fiNo;
  final String? workflowState;
  final String? employee;
  final String? warehouse;

  factory Datum.fromJson(Map<String, dynamic> json){
    return Datum(
      name: json["name"],
      subcon: json["subcon"],
      processName: json["process_name"],
      workOrdNo: json["work_ord_no"],
      date: DateTime.tryParse(json["date"] ?? ""),
      fiNo: json["fi_no"],
      workflowState: json["workflow_state"],
      employee: json["employee"],
      warehouse: json["warehouse"],
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "subcon": subcon,
    "process_name": processName,
    "work_ord_no": workOrdNo,
    "date": "${date?.year.toString().padLeft(4)}-${date?.month.toString().padLeft(2)}-${date?.day.toString().padLeft(2)}",
    "fi_no": fiNo,
    "workflow_state": workflowState,
    "employee": employee,
    "warehouse": warehouse,
  };

}

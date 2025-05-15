// model/json_model/po_json.dart

class Po {
  Po({required this.data});

  final List<Datumpo> data;

  factory Po.fromJson(Map<String, dynamic> json) {
    return Po(
      data:
          json["data"] == null
              ? []
              : List<Datumpo>.from(
                json["data"]!.map((x) => Datumpo.fromJson(x)),
              ),
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data.map((x) => x.toJson()).toList(),
  };
}

class Datumpo {
  Datumpo({
    this.name,
    this.company,
    this.supplier,
    this.type,
    this.orderType,
    this.dueDate,
    this.workOrdNo,
    this.workflowState,
  });

  final String? company;
  final String? name;
  final String? supplier;
  final String? type;
  final String? orderType;
  final DateTime? dueDate;
  final String? workOrdNo;
  final String? workflowState;

  factory Datumpo.fromJson(Map<String, dynamic> json) {
    return Datumpo(
      company: json["company"],
      name: json["name"],
      supplier: json["supplier"],
      type: json["type"],
      orderType: json["order_type"],
      dueDate:
          json["due_date"] != null ? DateTime.tryParse(json["due_date"]) : null,
      workOrdNo: json["work_ord_no"],
      workflowState: json["workflow_state"],
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "company": company,
    "supplier": supplier,
    "type": type,
    "order_type": orderType,
    "due_date":
        dueDate != null
            ? "${dueDate?.year.toString().padLeft(4, '0')}-${dueDate?.month.toString().padLeft(2, '0')}-${dueDate?.day.toString().padLeft(2, '0')}"
            : null,
    "work_ord_no": workOrdNo,
    "workflow_state": workflowState,
  };
}

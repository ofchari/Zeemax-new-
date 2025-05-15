class Order {
  Order({
    required this.data,
  });

  final List<Datumord> data;

  factory Order.fromJson(Map<String, dynamic> json){
    return Order(
      data: json["data"] == null ? [] : List<Datumord>.from(json["data"]!.map((x) => Datumord.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data.map((x) => x.toJson()).toList(),
  };

}

class Datumord {
  Datumord({
    required this.name,
    required this.company,
    required this.date,
    required this.buyer,
    required this.dueDate,
    required this.orderNo,
    required this.workflowState,
    required this.consignee,
    required this.priority,
    required this.product,
    required this.allSize,
  });

  final String? name;
  final String? company;
  final DateTime? date;
  final String? buyer;
  final DateTime? dueDate;
  final String? orderNo;
  final String? workflowState;
  final String? consignee;
  final String? priority;
  final String? product;
  final int? allSize;

  factory Datumord.fromJson(Map<String, dynamic> json){
    return Datumord(
      name: json["name"],
      company: json["company"],
      date: DateTime.tryParse(json["date"] ?? ""),
      buyer: json["buyer"],
      dueDate: DateTime.tryParse(json["due_date"] ?? ""),
      orderNo: json["order_no"],
      workflowState: json["workflow_state"],
      consignee: json["consignee"],
      priority: json["priority"],
      product: json["product"],
      allSize: json["all_size"],
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "company": company,
    "date": "${date?.year.toString().padLeft(4)}-${date?.month.toString().padLeft(2)}-${date?.day.toString().padLeft(2)}",
    "buyer": buyer,
    "due_date": "${dueDate?.year.toString().padLeft(4)}-${dueDate?.month.toString().padLeft(2)}-${dueDate?.day.toString().padLeft(2)}",
    "order_no": orderNo,
    "workflow_state": workflowState,
    "consignee": consignee,
    "priority": priority,
    "product": product,
    "all_size": allSize,
  };

}

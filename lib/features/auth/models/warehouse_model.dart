class WarehouseModel {
  final int id;
  final String warehouseName;
  final String type;
  final String governorate;
  final String location;
  final String companyName;
  final double? area;
  final double? financialBudgets;

  WarehouseModel({
    required this.id,
    required this.warehouseName,
    required this.type,
    required this.governorate,
    required this.location,
    required this.companyName,
    this.area,
    this.financialBudgets,
  });

  factory WarehouseModel.fromJson(Map<String, dynamic> json) {
    return WarehouseModel(
      id: json['id'],
      warehouseName: json['warehouse_name'] ?? '',
      type: json['type'] ?? '',
      governorate: json['governorate'] ?? '',
      location: json['location'] ?? '',
      companyName: json['company_name'] ?? '',
      area: json['area'] != null
          ? double.tryParse(json['area'].toString())
          : null,
      financialBudgets: json['financial_budgets'] != null
          ? double.tryParse(json['financial_budgets'].toString())
          : null,
    );
  }
}

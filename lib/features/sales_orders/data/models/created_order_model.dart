import '../../../../core/utils/json_map.dart';
import '../../domain/entities/created_order_entity.dart';

class CreatedOrderModel {
  const CreatedOrderModel({
    required this.salesOrderNumber,
    required this.dataAreaId,
    required this.custAccount,
    required this.inventLocationId,
    this.inventSiteId,
    this.currencyCode,
    this.orderTakerPersonnelNumber,
  });

  final String salesOrderNumber;
  final String dataAreaId;
  final String custAccount;
  final String inventLocationId;
  final String? inventSiteId;
  final String? currencyCode;
  final String? orderTakerPersonnelNumber;

  factory CreatedOrderModel.fromJson(Map<String, dynamic> json) {
    return CreatedOrderModel(
      salesOrderNumber: JsonMap.stringAny(json, <String>[
        'salesOrderNumber',
        'salesId',
        'SalesOrderNumber',
      ]),
      dataAreaId: JsonMap.stringAny(json, <String>[
        'dataAreaId',
        'dataArea',
        'company',
      ]),
      custAccount: JsonMap.stringAny(json, <String>[
        'custAccount',
        'customerAccount',
      ]),
      inventLocationId: JsonMap.string(json, 'inventLocationId'),
      inventSiteId: JsonMap.stringOrNull(json, 'inventSiteId'),
      currencyCode: JsonMap.stringOrNull(json, 'currencyCode'),
      orderTakerPersonnelNumber: JsonMap.stringOrNull(
        json,
        'orderTakerPersonnelNumber',
      ),
    );
  }

  CreatedOrderEntity toEntity() => CreatedOrderEntity(
    salesOrderNumber: salesOrderNumber,
    dataAreaId: dataAreaId,
    custAccount: custAccount,
    inventLocationId: inventLocationId,
    inventSiteId: inventSiteId,
    currencyCode: currencyCode,
    orderTakerPersonnelNumber: orderTakerPersonnelNumber,
  );
}

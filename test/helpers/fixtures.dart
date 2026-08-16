/// Live staging fixtures + sample JSON for model / datasource unit tests.
abstract final class Fixtures {
  static const String e2eBaseUrl = 'https://salesorderapp.logictec.online';
  static const String loginCompany = 'logic-trial';
  static const String personnelNumber = '1006';
  static const String password = '123';
  static const String legalEntity = 'mm';
  static const String barcode = '6287007961754';
  static const String itemNumber = 'BG410.003';
  static const String salesId = 'MM-245265';
  static const String warehouse = 'MMS000WH';
  static const String custAccount = '20-10004';
  static const String unknownBarcode = '0000000000000';

  static const Map<String, dynamic> sampleBarcodeJson = <String, dynamic>{
    'barcode': barcode,
    'itemNumber': '  BG410.003  ',
    'productName': 'Bag Item',
    'productDescription': 'Trial barcode product',
    'unitId': 'pcs',
    'dataArea': legalEntity,
  };

  static const Map<String, dynamic> sampleOrderHeaderJson = <String, dynamic>{
    'salesId': salesId,
    'custAccount': custAccount,
    'salesName': 'Trial Customer',
    'dataArea': legalEntity,
    'priceGroupId': 'RETAIL',
    'inventLocationId': warehouse,
    'inventSiteId': 'MM',
    'salesStatus': 'Backorder',
    'documentStatus': 'None',
    'createdDateTime': '2025-01-01T00:00:00Z',
  };

  static const Map<String, dynamic> sampleOrderLineJson = <String, dynamic>{
    'recordId': 1,
    'salesId': salesId,
    'itemId': itemNumber,
    'productName': 'Bag Item',
    'salesQty': 2,
    'salesUnit': 'pcs',
    'lineNum': 1,
    'dataArea': legalEntity,
  };

  static const Map<String, dynamic> samplePriceJson = <String, dynamic>{
    'itemNumber': '  BG410.003  ',
    'price': 12.5,
    'unitId': 'pcs',
    'customerAccountNumber': custAccount,
    'priceCustomerGroupCode': 'RETAIL',
    'dataArea': legalEntity,
  };

  static const Map<String, dynamic> sampleInventoryJson = <String, dynamic>{
    'itemNumber': '  BG410.003  ',
    'warehouseId': warehouse,
    'availableSalesQuantity': 25,
    'availableOnHandQuantity': 30,
    'unit': 'pcs',
    'productName': 'Bag Item',
  };

  static const Map<String, dynamic> sampleActivationUser1006 = <String, dynamic>{
    'personnelNumber': personnelNumber,
    'workerRecId': 5637227826,
    'name': 'محمد عفيف',
    'userId': 'm.afif',
    'activationRecId': 5637144576,
    'isActive': true,
    'userInfoEnable': true,
    'company': 'mm',
    'companies': <Map<String, dynamic>>[
      <String, dynamic>{'code': 'mm', 'name': 'mm', 'groupId': null},
    ],
    'retailChannelTableRecId': 5637152827,
    'retailChannelId': '912',
    'channelType': 4,
    'inventLocation': 'MMS000WH',
    'inventLocationDataAreaId': 'mm',
    'currency': 'SAR',
    'defaultCustAccount': '10-10002',
    'defaultCustDataAreaId': 'mm',
    'activeCompany': 'mm',
    'activeWarehouse': 'MMS000WH',
    'needsWarehouseSelection': false,
  };

  static const Map<String, dynamic> sampleActivationUser12344 =
      <String, dynamic>{
    'personnelNumber': '12344',
    'workerRecId': 5637227999,
    'name': 'مروان وهاس',
    'userId': 'm.wahas',
    'activationRecId': 5637144577,
    'isActive': true,
    'userInfoEnable': true,
    'company': 'PLTR',
    'companies': <Map<String, dynamic>>[
      <String, dynamic>{'code': 'PLTR', 'name': 'PLTR', 'groupId': null},
    ],
    'retailChannelTableRecId': null,
    'retailChannelId': '',
    'channelType': null,
    'inventLocation': '',
    'inventLocationDataAreaId': '',
    'currency': '',
    'defaultCustAccount': '',
    'defaultCustDataAreaId': '',
    'activeCompany': 'PLTR',
    'activeWarehouse': '',
    'needsWarehouseSelection': true,
  };

  static const Map<String, dynamic> sampleLoginDataJson = <String, dynamic>{
    'accessToken': 'access-token-sample',
    'refreshToken': 'refresh-token-sample',
    'user': sampleActivationUser1006,
  };

  static const Map<String, dynamic> sampleLoginDataIncompleteJson =
      <String, dynamic>{
    'accessToken': 'access-token-12344',
    'refreshToken': 'refresh-token-12344',
    'user': sampleActivationUser12344,
  };

  static const Map<String, dynamic> sampleFailedLineJson = <String, dynamic>{
    'id': 'fl-1',
    'jobId': 'job-1',
    'barcode': barcode,
    'itemNumber': '  BG410.003  ',
    'quantity': 3,
    'status': 'Failed',
    'commentAr': 'فشل',
    'commentEn': 'Failed',
    'createdAt': '2025-01-01T00:00:00Z',
  };

  static const Map<String, dynamic> sampleLineItemJson = <String, dynamic>{
    'id': 'li-1',
    'barcode': barcode,
    'itemNumber': '  BG410.003  ',
    'quantity': 1,
    'status': 'Ok',
    'commentAr': null,
    'commentEn': null,
    'price': 12.5,
    'unitId': 'pcs',
    'availableQty': 25,
  };
}

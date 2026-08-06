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

  static const Map<String, dynamic> sampleLoginDataJson = <String, dynamic>{
    'accessToken': 'access-token-sample',
    'refreshToken': 'refresh-token-sample',
    'user': <String, dynamic>{
      'personnelNumber': personnelNumber,
      'workerRecId': 1006,
      'name': 'Trial User',
      'companies': <Map<String, dynamic>>[
        <String, dynamic>{
          'code': 'mm',
          'name': 'MM Company',
          'groupId': 'GRP-MM',
        },
        <String, dynamic>{
          'code': 'rest',
          'name': 'REST Company',
          'groupId': 'GRP-REST',
        },
      ],
    },
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

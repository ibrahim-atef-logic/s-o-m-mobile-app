import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/catalog/data/models/barcode_item_model.dart';
import 'package:logic_retail_mobile/features/catalog/data/models/failed_line_model.dart';
import 'package:logic_retail_mobile/features/catalog/data/models/line_item_result_model.dart';
import 'package:logic_retail_mobile/features/catalog/data/models/price_info_model.dart';
import 'package:logic_retail_mobile/features/catalog/data/models/warehouse_on_hand_model.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  test('BarcodeItemModel trims padded itemNumber', () {
    final BarcodeItemModel model = BarcodeItemModel.fromJson(
      Fixtures.sampleBarcodeJson,
    );
    expect(model.itemNumber, Fixtures.itemNumber);
    expect(model.barcode, Fixtures.barcode);
    expect(model.toEntity().itemNumber, Fixtures.itemNumber);
  });

  test('BarcodeItemModel leading space on D365 item id is not kept', () {
    final BarcodeItemModel model = BarcodeItemModel.fromJson(<String, dynamic>{
      'barcode': '6287007961754',
      'itemNumber': ' BG410.003',
      'productName': 'Bag',
      'productDescription': '',
      'unitId': ' حبة ',
      'dataArea': 'mm',
    });
    expect(model.itemNumber, 'BG410.003');
    expect(model.itemNumber.length, 9);
    expect(model.itemNumber.codeUnits.first, 0x42);
    expect(model.itemNumber.codeUnits.last, 0x33);
    expect(model.unitId, 'حبة');
  });

  test('PriceInfoModel maps finalPrice and currency only', () {
    final PriceInfoModel model = PriceInfoModel.fromJson(
      Fixtures.samplePriceJson,
    );
    expect(model.itemNumber, Fixtures.itemNumber);
    expect(model.price, 12.5);
    expect(model.currency, 'SAR');
    expect(model.found, isTrue);
    expect(model.toEntity().price, 12.5);
  });

  test('PriceInfoModel found false when finalPrice missing', () {
    final PriceInfoModel model = PriceInfoModel.fromJson(<String, dynamic>{
      'itemId': 'X',
      'found': true,
      'price': 99.0,
      'currency': 'SAR',
      'salesUnit': 'pcs',
    });
    expect(model.found, isFalse);
    expect(model.price, 0);
  });

  test('WarehouseOnHandModel trims itemNumber', () {
    final WarehouseOnHandModel model = WarehouseOnHandModel.fromJson(
      Fixtures.sampleInventoryJson,
    );
    expect(model.itemNumber, Fixtures.itemNumber);
    expect(model.availableSalesQuantity, 25);
    expect(model.toEntity().warehouseId, Fixtures.warehouse);
  });

  test('FailedLineModel trims optional itemNumber', () {
    final FailedLineModel model = FailedLineModel.fromJson(
      Fixtures.sampleFailedLineJson,
    );
    expect(model.itemNumber, Fixtures.itemNumber);
    expect(model.toEntity().id, 'fl-1');
  });

  test('LineItemResultModel trims itemNumber', () {
    final LineItemResultModel model = LineItemResultModel.fromJson(
      Fixtures.sampleLineItemJson,
    );
    expect(model.itemNumber, Fixtures.itemNumber);
    expect(model.toEntity().unitId, 'pcs');
  });
}

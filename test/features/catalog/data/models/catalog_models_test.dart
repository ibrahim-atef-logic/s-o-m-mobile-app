import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/catalog/data/models/barcode_item_model.dart';
import 'package:logic_retail_mobile/features/catalog/data/models/failed_line_model.dart';
import 'package:logic_retail_mobile/features/catalog/data/models/line_item_result_model.dart';
import 'package:logic_retail_mobile/features/catalog/data/models/price_info_model.dart';
import 'package:logic_retail_mobile/features/catalog/data/models/warehouse_on_hand_model.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  test('BarcodeItemModel trims padded itemNumber', () {
    final BarcodeItemModel model =
        BarcodeItemModel.fromJson(Fixtures.sampleBarcodeJson);
    expect(model.itemNumber, Fixtures.itemNumber);
    expect(model.barcode, Fixtures.barcode);
    expect(model.toEntity().itemNumber, Fixtures.itemNumber);
  });

  test('PriceInfoModel trims itemNumber and maps price', () {
    final PriceInfoModel model =
        PriceInfoModel.fromJson(Fixtures.samplePriceJson);
    expect(model.itemNumber, Fixtures.itemNumber);
    expect(model.price, 12.5);
    expect(model.toEntity().price, 12.5);
  });

  test('WarehouseOnHandModel trims itemNumber', () {
    final WarehouseOnHandModel model =
        WarehouseOnHandModel.fromJson(Fixtures.sampleInventoryJson);
    expect(model.itemNumber, Fixtures.itemNumber);
    expect(model.availableSalesQuantity, 25);
    expect(model.toEntity().warehouseId, Fixtures.warehouse);
  });

  test('FailedLineModel trims optional itemNumber', () {
    final FailedLineModel model =
        FailedLineModel.fromJson(Fixtures.sampleFailedLineJson);
    expect(model.itemNumber, Fixtures.itemNumber);
    expect(model.toEntity().id, 'fl-1');
  });

  test('LineItemResultModel trims itemNumber', () {
    final LineItemResultModel model =
        LineItemResultModel.fromJson(Fixtures.sampleLineItemJson);
    expect(model.itemNumber, Fixtures.itemNumber);
    expect(model.toEntity().unitId, 'pcs');
  });
}

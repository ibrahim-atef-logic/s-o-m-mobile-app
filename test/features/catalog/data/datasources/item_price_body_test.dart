import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/features/catalog/data/datasources/catalog_remote_parse.dart';

void main() {
  test('item-price itemId is exactly BG410.003 with barcode unit حبة', () {
    final Map<String, Object> body = CatalogRemoteParse.itemPriceBody(
      company: ' mm ',
      itemId: ' BG410.003 ',
      salesUnitId: ' حبة ',
    );

    expect(body['company'], 'mm');
    expect(body['itemId'], 'BG410.003');
    expect(body['itemId'], isNot(startsWith(' ')));
    expect((body['itemId']! as String).length, 9);
    expect((body['itemId']! as String).codeUnits, <int>[
      0x42,
      0x47,
      0x34,
      0x31,
      0x30,
      0x2E,
      0x30,
      0x30,
      0x33,
    ]);
    expect(body['salesUnitId'], 'حبة');
    expect((body['salesUnitId']! as String).codeUnits, <int>[
      0x062D,
      0x0628,
      0x0629,
    ]);
    expect(body.containsKey('warehouseId'), isFalse);
    expect(body.containsKey('channelRecId'), isFalse);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:logic_retail_mobile/core/error/api_error_code.dart';
import 'package:logic_retail_mobile/core/error/failures.dart';

void main() {
  test('reads the code the interceptor prefixed onto the message', () {
    const Failure failure = ServerFailure(
      'WAREHOUSE_REQUIRED: No warehouse for this user',
    );

    expect(failure.apiCode, 'WAREHOUSE_REQUIRED');
    expect(failure.isWarehouseRequired, isTrue);
    expect(failure.isForbiddenCompany, isFalse);
  });

  test('flags forbidden company and dynamics outages', () {
    const Failure forbidden = ServerFailure(
      'FORBIDDEN_COMPANY: Company not allowed for token',
    );
    const Failure dynamics = ServerFailure('DYNAMICS_UNAVAILABLE: retry later');
    const Failure dynamicsError = ServerFailure(
      'DYNAMICS_ERROR: Conversion between PCS and حبة does not exist',
    );

    expect(forbidden.isForbiddenCompany, isTrue);
    expect(dynamics.isDynamicsOutage, isTrue);
    expect(dynamicsError.isDynamicsOutage, isFalse);
    expect(dynamicsError.isDynamicsError, isTrue);
    expect(dynamicsError.isUnitConversionError, isTrue);
    expect(dynamics.isWarehouseRequired, isFalse);
  });

  test('flags LINE_ALREADY_EXISTS from the envelope code', () {
    const Failure failure = ServerFailure(
      'LINE_ALREADY_EXISTS: Item BG410.003 is already on sales order MM-245265.',
    );

    expect(failure.apiCode, 'LINE_ALREADY_EXISTS');
    expect(failure.isLineAlreadyExists, isTrue);
    expect(failure.isDynamicsOutage, isFalse);
  });

  test('validation code is recognized for inline field errors', () {
    const Failure failure = ValidationFailure(
      'VALIDATION_ERROR: custAccount is required',
    );

    expect(failure.isValidationCode, isTrue);
  });

  test('flags catalog, stock, lock, and max-lines codes', () {
    const Failure barcode = ServerFailure(
      'BARCODE_NOT_FOUND: Barcode not found',
    );
    const Failure item = ServerFailure('ITEM_NOT_FOUND: Item not found');
    const Failure line = ServerFailure('LINE_NOT_FOUND: Line not found');
    const Failure locked = ServerFailure(
      'ORDER_NOT_EDITABLE: Order confirmed / الأمر مؤكد',
    );
    const Failure closed = ServerFailure('SO_NOT_OPEN: not open');
    const Failure stock = ServerFailure('NO_STOCK: none');
    const Failure qty = ServerFailure('QTY_EXCEEDS_STOCK: too many');
    const Failure max = ValidationFailure('MAX_LINES: Quick add allows max 10 lines');

    expect(barcode.isItemNotFound, isTrue);
    expect(item.isItemNotFound, isTrue);
    expect(line.isLineNotFound, isTrue);
    expect(locked.isOrderNotEditable, isTrue);
    expect(closed.isSoNotOpen, isTrue);
    expect(closed.isOrderLockedForEdit, isTrue);
    expect(stock.isNoStock, isTrue);
    expect(qty.isQtyExceedsStock, isTrue);
    expect(max.isMaxLines, isTrue);
    expect(item.isNoPrice, isFalse);
  });

  test('plain messages have no code', () {
    const Failure network = NetworkFailure();
    const Failure prose = ServerFailure('Something broke: badly');

    expect(network.apiCode, isNull);
    expect(prose.apiCode, isNull);
  });
}

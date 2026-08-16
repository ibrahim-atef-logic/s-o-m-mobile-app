// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sales Orders Management';

  @override
  String get welcome => 'Welcome';

  @override
  String get helloTitle => 'Sales Orders Management';

  @override
  String get helloSubtitle =>
      'Scan, add, and manage sales order lines on the floor';

  @override
  String get login => 'Login';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get logout => 'Logout';

  @override
  String get personnelNumber => 'Personnel number';

  @override
  String get personnelNumberHint => 'Employee number or user id';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get companyCode => 'Environment / tenant code';

  @override
  String get companyCodeHint => 'Environment / tenant code';

  @override
  String get errorCompanyRequired => 'Environment code is required';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get errorPersonnelRequired => 'Personnel number is required';

  @override
  String get errorPasswordRequired => 'Password is required';

  @override
  String get selectCompany => 'Select company';

  @override
  String get selectCompanyHint => 'Choose the company to work with';

  @override
  String get noCompanies => 'No companies available';

  @override
  String get searchCompanies => 'Search companies';

  @override
  String get mySalesOrders => 'My sales orders';

  @override
  String ordersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
      zero: 'No orders',
    );
    return '$_temp0';
  }

  @override
  String get searchOrders => 'Search orders';

  @override
  String get noOrders => 'No open sales orders';

  @override
  String get noOrdersMatchSearch => 'No orders match your search';

  @override
  String get salesOrderDetails => 'Sales order details';

  @override
  String get orderSummary => 'Order summary';

  @override
  String get viewLines => 'View lines';

  @override
  String get viewLinesDesc => 'Browse existing order lines';

  @override
  String get fullAdd => 'Full add';

  @override
  String get fullAddDesc => 'Lookup price and stock, then add';

  @override
  String get quickAdd => 'Quick add';

  @override
  String get quickAddDesc => 'Scan and batch submit up to 10 lines';

  @override
  String get failedLines => 'Failed lines';

  @override
  String get failedLinesDesc => 'Review lines that failed to post';

  @override
  String get failedLinesEmpty => 'No failed lines';

  @override
  String get failureReason => 'Reason';

  @override
  String get addItem => 'Add item';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get scanBarcode => 'Scan barcode';

  @override
  String get scanWithCamera => 'Scan with camera';

  @override
  String get toggleTorch => 'Toggle torch';

  @override
  String get lastScanned => 'Last scanned';

  @override
  String get barcode => 'Barcode';

  @override
  String get lookup => 'Lookup';

  @override
  String get getQuantity => 'Get quantity';

  @override
  String get availableQty => 'Available quantity';

  @override
  String get price => 'Price';

  @override
  String get submit => 'Submit';

  @override
  String get submitBatch => 'Submit batch';

  @override
  String get cartEmpty => 'Cart is empty';

  @override
  String get lineAdded => 'Line added';

  @override
  String get batchSubmitted => 'Batch submitted';

  @override
  String get submitResultTitle => 'Submit result';

  @override
  String succeededCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count succeeded',
      one: '1 succeeded',
      zero: '0 succeeded',
    );
    return '$_temp0';
  }

  @override
  String failedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count failed',
      one: '1 failed',
      zero: '0 failed',
    );
    return '$_temp0';
  }

  @override
  String get stepScan => 'Scan';

  @override
  String get stepQuantity => 'Quantity';

  @override
  String get stepAdd => 'Add';

  @override
  String get stockInStock => 'In stock';

  @override
  String get stockLow => 'Low stock';

  @override
  String get stockOut => 'Out of stock';

  @override
  String cartItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String get removeFromCart => 'Remove from cart';

  @override
  String get customer => 'Customer';

  @override
  String get warehouse => 'Warehouse';

  @override
  String get priceGroup => 'Price group';

  @override
  String get item => 'Item';

  @override
  String get quantity => 'Quantity';

  @override
  String get qtyLabel => 'Qty';

  @override
  String get unitPrice => 'Unit price';

  @override
  String get lineTotal => 'Line total';

  @override
  String linesTitle(String salesId) {
    return 'Lines · $salesId';
  }

  @override
  String get noLines => 'No lines found';

  @override
  String linesSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines',
      one: '1 line',
      zero: 'No lines',
    );
    return '$_temp0';
  }

  @override
  String get errorBarcodeRequired => 'Barcode is required';

  @override
  String get errorNoPrice => 'No price is defined for this product';

  @override
  String get errorNoStock => 'No available stock for this product';

  @override
  String get errorQtyInvalid => 'Quantity must be a whole number of at least 1';

  @override
  String get errorQtyExceeds => 'Quantity exceeds available stock';

  @override
  String get errorLookupRequired => 'Lookup the barcode first';

  @override
  String get errorMaxQuickLines => 'Quick add allows max 10 lines';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorNetwork => 'No internet connection';

  @override
  String get errorServer => 'Server error';

  @override
  String get errorAuth => 'Invalid credentials';

  @override
  String get errorAuthCompanyUnknown => 'Environment code is not registered';

  @override
  String get errorAuthCredentials => 'Invalid personnel number or password';

  @override
  String get errorAccountDisabled => 'Account is inactive in D365 / mobile';

  @override
  String get errorPasswordChangeFailed => 'Password could not be changed';

  @override
  String get errorWarehouseNotAssigned =>
      'No warehouse assigned / لم يتم تعيين مستودع';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileName => 'Name';

  @override
  String get profileUserId => 'User ID';

  @override
  String get profileActiveCompany => 'Company';

  @override
  String get profileDefaultWarehouse => 'Default warehouse';

  @override
  String get profileChannel => 'Branch';

  @override
  String get profileCurrency => 'Currency';

  @override
  String get profileDefaultCustomer => 'Default customer';

  @override
  String get warehouseNotAssignedBanner =>
      'Warehouse is not assigned / لم يتم تعيين مستودع. Warehouse picker is not available yet / اختيار المستودع غير متاح حالياً.';

  @override
  String get changePassword => 'Change password';

  @override
  String get oldPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm new password';

  @override
  String get errorPasswordMismatch =>
      'New password and confirmation do not match';

  @override
  String get errorPasswordSameAsOld =>
      'New password must be different from the current one';

  @override
  String get passwordChanged => 'Password changed';

  @override
  String get errorTimeout => 'Request timed out';

  @override
  String get errorSessionExpired => 'Session expired — please sign in again';

  @override
  String get errorDynamicsUnavailable =>
      'Dynamics environment is unavailable — try again shortly';

  @override
  String get errorValidation => 'Please check your input';

  @override
  String get errorCache => 'Could not read local data';

  @override
  String get errorMissingOrder => 'Missing order';

  @override
  String get errorMissingSession => 'Missing session';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get search => 'Search';

  @override
  String get refresh => 'Refresh';

  @override
  String get details => 'Details';

  @override
  String get back => 'Back';

  @override
  String get continueLabel => 'Continue';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';
}

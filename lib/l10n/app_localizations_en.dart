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
      'Create sales orders, scan items, and manage order lines';

  @override
  String get login => 'Login';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginWelcome => 'Welcome back';

  @override
  String get loginSubtitle => 'Enter your environment credentials to continue';

  @override
  String get loginSecureHint =>
      'Encrypted connection · credentials stay on this device';

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
  String get newSalesOrder => 'New sales order';

  @override
  String get createOrder => 'Create order';

  @override
  String orderCreated(String salesId) {
    return 'Order $salesId created';
  }

  @override
  String get selectCustomer => 'Select customer';

  @override
  String get searchCustomers => 'Search by account number or customer name';

  @override
  String get noCustomers => 'No matching customers';

  @override
  String customersResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get errorCustomersLoadFailed =>
      'Could not load customers, please try again';

  @override
  String get errorCustomerRequired => 'Select a customer first';

  @override
  String get noOrders => 'No open sales orders';

  @override
  String get noOrdersMatchSearch => 'No orders match your search';

  @override
  String get salesOrderDetails => 'Sales order details';

  @override
  String get orderSummary => 'Sales order summary';

  @override
  String get salesStatus => 'Sales status';

  @override
  String get documentStatus => 'Document status';

  @override
  String get linesCountLabel => 'Lines';

  @override
  String get addItems => 'Add items';

  @override
  String get addItemsDesc => 'Scan and add lines (auto or manual)';

  @override
  String get submitModeAuto => 'Automatic';

  @override
  String get submitModeManual => 'Manual';

  @override
  String get submitModeAutoHint =>
      'Posts to the order immediately on quantity Enter';

  @override
  String get submitModeManualHint => 'Review quantity, then tap Add';

  @override
  String get linePosted => 'Posted';

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
  String get addToCart => 'Add';

  @override
  String get copyError => 'Copy details';

  @override
  String get errorCopied => 'Error details copied';

  @override
  String get scanBarcode => 'Scan barcode';

  @override
  String get scanWithCamera => 'Scan with camera';

  @override
  String get hideCamera => 'Hide camera';

  @override
  String get searchByBarcode => 'Barcode';

  @override
  String get searchByItem => 'Item';

  @override
  String get deleteLine => 'Delete line';

  @override
  String get confirmDeleteLine => 'Remove this line from the order?';

  @override
  String get lineDeletePending =>
      'Line delete is not available on the server yet';

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
  String get orderTotal => 'Order total';

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
  String get errorPasswordChangeFailed =>
      'We couldn\'t change your password. Check your current password and try again.';

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
  String get profileWarehouse => 'Warehouse';

  @override
  String get profileSelectWarehouse => 'Select warehouse';

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
      'No warehouse is assigned to your account. Select a standard warehouse to continue.';

  @override
  String get selectWarehouse => 'Select warehouse';

  @override
  String get selectWarehouseHint =>
      'Choose the standard warehouse you work with';

  @override
  String get searchWarehouses => 'Search warehouses';

  @override
  String get noWarehouses =>
      'No standard warehouses are available for this company';

  @override
  String get noWarehousesMatchSearch => 'No warehouses match your search';

  @override
  String get errorWarehousesLoadFailed =>
      'Could not load warehouses, please try again';

  @override
  String get warehouseSelected => 'Warehouse selected';

  @override
  String get changeWarehouse => 'Change warehouse';

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
  String get passwordChanged => 'Your password was updated successfully.';

  @override
  String get errorTimeout => 'Request timed out';

  @override
  String get errorSessionExpired => 'Session expired — please sign in again';

  @override
  String get errorDynamicsUnavailable =>
      'Dynamics environment is unavailable — try again shortly';

  @override
  String get errorPriceFetchFailed => 'Could not fetch price';

  @override
  String get errorUnitConversion =>
      'Unit/price conversion is not available for this product';

  @override
  String get errorCustomerStopped =>
      'This customer is stopped in Dynamics and cannot be used for orders';

  @override
  String get errorLineAlreadyExists =>
      'This item is already on the sales order';

  @override
  String get errorItemNotFound => 'Item not found';

  @override
  String get errorBarcodeNotFoundTryItem =>
      'Barcode not found — try Item mode (صنف) if you typed an item number';

  @override
  String get errorForbiddenCompany =>
      'This company is not allowed for the current session';

  @override
  String get errorSoNotOpen => 'This sales order is not open for editing';

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

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get increaseQuantity => 'Increase quantity';
}

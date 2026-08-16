import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales Orders Management'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @helloTitle.
  ///
  /// In en, this message translates to:
  /// **'Sales Orders Management'**
  String get helloTitle;

  /// No description provided for @helloSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scan, add, and manage sales order lines on the floor'**
  String get helloSubtitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @personnelNumber.
  ///
  /// In en, this message translates to:
  /// **'Personnel number'**
  String get personnelNumber;

  /// No description provided for @personnelNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Employee number or user id'**
  String get personnelNumberHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @companyCode.
  ///
  /// In en, this message translates to:
  /// **'Environment / tenant code'**
  String get companyCode;

  /// No description provided for @companyCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Environment / tenant code'**
  String get companyCodeHint;

  /// No description provided for @errorCompanyRequired.
  ///
  /// In en, this message translates to:
  /// **'Environment code is required'**
  String get errorCompanyRequired;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @errorPersonnelRequired.
  ///
  /// In en, this message translates to:
  /// **'Personnel number is required'**
  String get errorPersonnelRequired;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get errorPasswordRequired;

  /// No description provided for @selectCompany.
  ///
  /// In en, this message translates to:
  /// **'Select company'**
  String get selectCompany;

  /// No description provided for @selectCompanyHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the company to work with'**
  String get selectCompanyHint;

  /// No description provided for @noCompanies.
  ///
  /// In en, this message translates to:
  /// **'No companies available'**
  String get noCompanies;

  /// No description provided for @searchCompanies.
  ///
  /// In en, this message translates to:
  /// **'Search companies'**
  String get searchCompanies;

  /// No description provided for @mySalesOrders.
  ///
  /// In en, this message translates to:
  /// **'My sales orders'**
  String get mySalesOrders;

  /// No description provided for @ordersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No orders} =1{1 order} other{{count} orders}}'**
  String ordersCount(int count);

  /// No description provided for @searchOrders.
  ///
  /// In en, this message translates to:
  /// **'Search orders'**
  String get searchOrders;

  /// No description provided for @newSalesOrder.
  ///
  /// In en, this message translates to:
  /// **'New sales order'**
  String get newSalesOrder;

  /// No description provided for @createOrder.
  ///
  /// In en, this message translates to:
  /// **'Create order'**
  String get createOrder;

  /// No description provided for @orderCreated.
  ///
  /// In en, this message translates to:
  /// **'Order {salesId} created'**
  String orderCreated(String salesId);

  /// No description provided for @selectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Select customer'**
  String get selectCustomer;

  /// No description provided for @searchCustomers.
  ///
  /// In en, this message translates to:
  /// **'Search by account or name'**
  String get searchCustomers;

  /// No description provided for @noCustomers.
  ///
  /// In en, this message translates to:
  /// **'No customers match this search'**
  String get noCustomers;

  /// No description provided for @errorCustomersLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load customers, please try again'**
  String get errorCustomersLoadFailed;

  /// No description provided for @errorCustomerRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a customer first'**
  String get errorCustomerRequired;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'No open sales orders'**
  String get noOrders;

  /// No description provided for @noOrdersMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No orders match your search'**
  String get noOrdersMatchSearch;

  /// No description provided for @salesOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Sales order details'**
  String get salesOrderDetails;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get orderSummary;

  /// No description provided for @viewLines.
  ///
  /// In en, this message translates to:
  /// **'View lines'**
  String get viewLines;

  /// No description provided for @viewLinesDesc.
  ///
  /// In en, this message translates to:
  /// **'Browse existing order lines'**
  String get viewLinesDesc;

  /// No description provided for @fullAdd.
  ///
  /// In en, this message translates to:
  /// **'Full add'**
  String get fullAdd;

  /// No description provided for @fullAddDesc.
  ///
  /// In en, this message translates to:
  /// **'Lookup price and stock, then add'**
  String get fullAddDesc;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickAdd;

  /// No description provided for @quickAddDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan and batch submit up to 10 lines'**
  String get quickAddDesc;

  /// No description provided for @failedLines.
  ///
  /// In en, this message translates to:
  /// **'Failed lines'**
  String get failedLines;

  /// No description provided for @failedLinesDesc.
  ///
  /// In en, this message translates to:
  /// **'Review lines that failed to post'**
  String get failedLinesDesc;

  /// No description provided for @failedLinesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No failed lines'**
  String get failedLinesEmpty;

  /// No description provided for @failureReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get failureReason;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan barcode'**
  String get scanBarcode;

  /// No description provided for @scanWithCamera.
  ///
  /// In en, this message translates to:
  /// **'Scan with camera'**
  String get scanWithCamera;

  /// No description provided for @toggleTorch.
  ///
  /// In en, this message translates to:
  /// **'Toggle torch'**
  String get toggleTorch;

  /// No description provided for @lastScanned.
  ///
  /// In en, this message translates to:
  /// **'Last scanned'**
  String get lastScanned;

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// No description provided for @lookup.
  ///
  /// In en, this message translates to:
  /// **'Lookup'**
  String get lookup;

  /// No description provided for @getQuantity.
  ///
  /// In en, this message translates to:
  /// **'Get quantity'**
  String get getQuantity;

  /// No description provided for @availableQty.
  ///
  /// In en, this message translates to:
  /// **'Available quantity'**
  String get availableQty;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @submitBatch.
  ///
  /// In en, this message translates to:
  /// **'Submit batch'**
  String get submitBatch;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cartEmpty;

  /// No description provided for @lineAdded.
  ///
  /// In en, this message translates to:
  /// **'Line added'**
  String get lineAdded;

  /// No description provided for @batchSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Batch submitted'**
  String get batchSubmitted;

  /// No description provided for @submitResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit result'**
  String get submitResultTitle;

  /// No description provided for @succeededCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 succeeded} =1{1 succeeded} other{{count} succeeded}}'**
  String succeededCount(int count);

  /// No description provided for @failedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 failed} =1{1 failed} other{{count} failed}}'**
  String failedCount(int count);

  /// No description provided for @stepScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get stepScan;

  /// No description provided for @stepQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get stepQuantity;

  /// No description provided for @stepAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get stepAdd;

  /// No description provided for @stockInStock.
  ///
  /// In en, this message translates to:
  /// **'In stock'**
  String get stockInStock;

  /// No description provided for @stockLow.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get stockLow;

  /// No description provided for @stockOut.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get stockOut;

  /// No description provided for @cartItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String cartItemCount(int count);

  /// No description provided for @removeFromCart.
  ///
  /// In en, this message translates to:
  /// **'Remove from cart'**
  String get removeFromCart;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @warehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get warehouse;

  /// No description provided for @priceGroup.
  ///
  /// In en, this message translates to:
  /// **'Price group'**
  String get priceGroup;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @qtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qtyLabel;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get unitPrice;

  /// No description provided for @lineTotal.
  ///
  /// In en, this message translates to:
  /// **'Line total'**
  String get lineTotal;

  /// No description provided for @linesTitle.
  ///
  /// In en, this message translates to:
  /// **'Lines · {salesId}'**
  String linesTitle(String salesId);

  /// No description provided for @noLines.
  ///
  /// In en, this message translates to:
  /// **'No lines found'**
  String get noLines;

  /// No description provided for @linesSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No lines} =1{1 line} other{{count} lines}}'**
  String linesSummary(int count);

  /// No description provided for @errorBarcodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Barcode is required'**
  String get errorBarcodeRequired;

  /// No description provided for @errorNoPrice.
  ///
  /// In en, this message translates to:
  /// **'No price is defined for this product'**
  String get errorNoPrice;

  /// No description provided for @errorNoStock.
  ///
  /// In en, this message translates to:
  /// **'No available stock for this product'**
  String get errorNoStock;

  /// No description provided for @errorQtyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be a whole number of at least 1'**
  String get errorQtyInvalid;

  /// No description provided for @errorQtyExceeds.
  ///
  /// In en, this message translates to:
  /// **'Quantity exceeds available stock'**
  String get errorQtyExceeds;

  /// No description provided for @errorLookupRequired.
  ///
  /// In en, this message translates to:
  /// **'Lookup the barcode first'**
  String get errorLookupRequired;

  /// No description provided for @errorMaxQuickLines.
  ///
  /// In en, this message translates to:
  /// **'Quick add allows max 10 lines'**
  String get errorMaxQuickLines;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get errorServer;

  /// No description provided for @errorAuth.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get errorAuth;

  /// No description provided for @errorAuthCompanyUnknown.
  ///
  /// In en, this message translates to:
  /// **'Environment code is not registered'**
  String get errorAuthCompanyUnknown;

  /// No description provided for @errorAuthCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid personnel number or password'**
  String get errorAuthCredentials;

  /// No description provided for @errorAccountDisabled.
  ///
  /// In en, this message translates to:
  /// **'Account is inactive in D365 / mobile'**
  String get errorAccountDisabled;

  /// No description provided for @errorPasswordChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Password could not be changed'**
  String get errorPasswordChangeFailed;

  /// No description provided for @errorWarehouseNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'No warehouse assigned / لم يتم تعيين مستودع'**
  String get errorWarehouseNotAssigned;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// No description provided for @profileUserId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get profileUserId;

  /// No description provided for @profileActiveCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get profileActiveCompany;

  /// No description provided for @profileDefaultWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Default warehouse'**
  String get profileDefaultWarehouse;

  /// No description provided for @profileChannel.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get profileChannel;

  /// No description provided for @profileCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get profileCurrency;

  /// No description provided for @profileDefaultCustomer.
  ///
  /// In en, this message translates to:
  /// **'Default customer'**
  String get profileDefaultCustomer;

  /// No description provided for @warehouseNotAssignedBanner.
  ///
  /// In en, this message translates to:
  /// **'No warehouse is assigned to your account. Select a standard warehouse to continue.'**
  String get warehouseNotAssignedBanner;

  /// No description provided for @selectWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Select warehouse'**
  String get selectWarehouse;

  /// No description provided for @selectWarehouseHint.
  ///
  /// In en, this message translates to:
  /// **'Choose the standard warehouse you work with'**
  String get selectWarehouseHint;

  /// No description provided for @searchWarehouses.
  ///
  /// In en, this message translates to:
  /// **'Search warehouses'**
  String get searchWarehouses;

  /// No description provided for @noWarehouses.
  ///
  /// In en, this message translates to:
  /// **'No standard warehouses are available for this company'**
  String get noWarehouses;

  /// No description provided for @errorWarehousesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load warehouses, please try again'**
  String get errorWarehousesLoadFailed;

  /// No description provided for @warehouseSelected.
  ///
  /// In en, this message translates to:
  /// **'Warehouse selected'**
  String get warehouseSelected;

  /// No description provided for @changeWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Change warehouse'**
  String get changeWarehouse;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmPassword;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'New password and confirmation do not match'**
  String get errorPasswordMismatch;

  /// No description provided for @errorPasswordSameAsOld.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from the current one'**
  String get errorPasswordSameAsOld;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get passwordChanged;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out'**
  String get errorTimeout;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired — please sign in again'**
  String get errorSessionExpired;

  /// No description provided for @errorDynamicsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Dynamics environment is unavailable — try again shortly'**
  String get errorDynamicsUnavailable;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check your input'**
  String get errorValidation;

  /// No description provided for @errorCache.
  ///
  /// In en, this message translates to:
  /// **'Could not read local data'**
  String get errorCache;

  /// No description provided for @errorMissingOrder.
  ///
  /// In en, this message translates to:
  /// **'Missing order'**
  String get errorMissingOrder;

  /// No description provided for @errorMissingSession.
  ///
  /// In en, this message translates to:
  /// **'Missing session'**
  String get errorMissingSession;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

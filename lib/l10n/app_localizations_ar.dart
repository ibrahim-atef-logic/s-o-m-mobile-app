// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'إدارة أوامر المبيعات';

  @override
  String get welcome => 'مرحباً';

  @override
  String get helloTitle => 'إدارة أوامر المبيعات';

  @override
  String get helloSubtitle => 'امسح وأضف وأدر أسطر أوامر المبيعات في الموقع';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get personnelNumber => 'رقم الموظف';

  @override
  String get personnelNumberHint => 'رقم الموظف أو المعرّف';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get companyCode => 'كود البيئة / المستأجر';

  @override
  String get companyCodeHint => 'كود البيئة / المستأجر';

  @override
  String get errorCompanyRequired => 'كود البيئة مطلوب';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get errorPersonnelRequired => 'رقم الموظف مطلوب';

  @override
  String get errorPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get selectCompany => 'اختر الشركة';

  @override
  String get selectCompanyHint => 'اختر الشركة للعمل عليها';

  @override
  String get noCompanies => 'لا توجد شركات متاحة';

  @override
  String get searchCompanies => 'بحث عن الشركات';

  @override
  String get mySalesOrders => 'أوامر المبيعات';

  @override
  String ordersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أوامر',
      one: 'أمر واحد',
      zero: 'لا توجد أوامر',
    );
    return '$_temp0';
  }

  @override
  String get searchOrders => 'بحث في الأوامر';

  @override
  String get newSalesOrder => 'أمر مبيعات جديد';

  @override
  String get createOrder => 'إنشاء الأمر';

  @override
  String orderCreated(String salesId) {
    return 'تم إنشاء الأمر $salesId';
  }

  @override
  String get selectCustomer => 'اختر العميل';

  @override
  String get searchCustomers => 'بحث برقم الحساب أو الاسم';

  @override
  String get noCustomers => 'لا يوجد عملاء مطابقون للبحث';

  @override
  String get errorCustomersLoadFailed => 'تعذر تحميل العملاء، حاول مرة أخرى';

  @override
  String get errorCustomerRequired => 'اختر العميل أولاً';

  @override
  String get noOrders => 'لا توجد أوامر مفتوحة';

  @override
  String get noOrdersMatchSearch => 'لا توجد أوامر مطابقة للبحث';

  @override
  String get salesOrderDetails => 'تفاصيل أمر المبيعات';

  @override
  String get orderSummary => 'ملخص الأمر';

  @override
  String get viewLines => 'عرض الأسطر';

  @override
  String get viewLinesDesc => 'تصفح أسطر الأمر الحالية';

  @override
  String get fullAdd => 'إضافة كاملة';

  @override
  String get fullAddDesc => 'ابحث عن السعر والمخزون ثم أضف';

  @override
  String get quickAdd => 'إضافة سريعة';

  @override
  String get quickAddDesc => 'امسح وأرسل حتى 10 أسطر دفعة واحدة';

  @override
  String get failedLines => 'الأسطر الفاشلة';

  @override
  String get failedLinesDesc => 'راجع الأسطر التي فشل ترحيلها';

  @override
  String get failedLinesEmpty => 'لا توجد أسطر فاشلة';

  @override
  String get failureReason => 'السبب';

  @override
  String get addItem => 'إضافة صنف';

  @override
  String get addToCart => 'إضافة إلى السلة';

  @override
  String get scanBarcode => 'مسح الباركود';

  @override
  String get scanWithCamera => 'المسح بالكاميرا';

  @override
  String get toggleTorch => 'تشغيل/إيقاف الفلاش';

  @override
  String get lastScanned => 'آخر مسح';

  @override
  String get barcode => 'الباركود';

  @override
  String get lookup => 'بحث';

  @override
  String get getQuantity => 'جلب الكمية';

  @override
  String get availableQty => 'الكمية المتاحة';

  @override
  String get price => 'السعر';

  @override
  String get submit => 'إرسال';

  @override
  String get submitBatch => 'إرسال الدفعة';

  @override
  String get cartEmpty => 'السلة فارغة';

  @override
  String get lineAdded => 'تمت إضافة السطر';

  @override
  String get batchSubmitted => 'تم إرسال الدفعة';

  @override
  String get submitResultTitle => 'نتيجة الإرسال';

  @override
  String succeededCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ناجح',
      one: '1 ناجح',
      zero: '0 ناجح',
    );
    return '$_temp0';
  }

  @override
  String failedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فاشل',
      one: '1 فاشل',
      zero: '0 فاشل',
    );
    return '$_temp0';
  }

  @override
  String get stepScan => 'مسح';

  @override
  String get stepQuantity => 'الكمية';

  @override
  String get stepAdd => 'إضافة';

  @override
  String get stockInStock => 'متوفر';

  @override
  String get stockLow => 'مخزون منخفض';

  @override
  String get stockOut => 'غير متوفر';

  @override
  String cartItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عناصر',
      one: 'عنصر واحد',
      zero: 'لا عناصر',
    );
    return '$_temp0';
  }

  @override
  String get removeFromCart => 'إزالة من السلة';

  @override
  String get customer => 'العميل';

  @override
  String get warehouse => 'المستودع';

  @override
  String get priceGroup => 'مجموعة السعر';

  @override
  String get item => 'الصنف';

  @override
  String get quantity => 'الكمية';

  @override
  String get qtyLabel => 'الكمية';

  @override
  String get unitPrice => 'سعر الوحدة';

  @override
  String get lineTotal => 'إجمالي السطر';

  @override
  String linesTitle(String salesId) {
    return 'الأسطر · $salesId';
  }

  @override
  String get noLines => 'لا توجد أسطر';

  @override
  String linesSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أسطر',
      one: 'سطر واحد',
      zero: 'لا أسطر',
    );
    return '$_temp0';
  }

  @override
  String get errorBarcodeRequired => 'الباركود مطلوب';

  @override
  String get errorNoPrice => 'لا يوجد سعر محدد لهذا المنتج';

  @override
  String get errorNoStock => 'لا يوجد مخزون متاح لهذا المنتج';

  @override
  String get errorQtyInvalid => 'يجب أن تكون الكمية عدداً صحيحاً لا يقل عن 1';

  @override
  String get errorQtyExceeds => 'الكمية تتجاوز المخزون المتاح';

  @override
  String get errorLookupRequired => 'ابحث عن الباركود أولاً';

  @override
  String get errorMaxQuickLines => 'الإضافة السريعة تسمح بحد أقصى 10 أسطر';

  @override
  String get errorGeneric => 'حدث خطأ ما';

  @override
  String get errorNetwork => 'لا يوجد اتصال بالإنترنت';

  @override
  String get errorServer => 'خطأ في الخادم';

  @override
  String get errorAuth => 'بيانات الدخول غير صحيحة';

  @override
  String get errorAuthCompanyUnknown => 'كود البيئة غير مسجّل';

  @override
  String get errorAuthCredentials => 'رقم الموظف أو كلمة المرور غير صحيحة';

  @override
  String get errorAccountDisabled => 'الحساب غير نشط في D365 / الموبايل';

  @override
  String get errorPasswordChangeFailed => 'تعذر تغيير كلمة المرور';

  @override
  String get errorWarehouseNotAssigned =>
      'لم يتم تعيين مستودع / No warehouse assigned';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileName => 'الاسم';

  @override
  String get profileUserId => 'معرّف المستخدم';

  @override
  String get profileActiveCompany => 'الشركة';

  @override
  String get profileDefaultWarehouse => 'المستودع الافتراضي';

  @override
  String get profileChannel => 'الفرع';

  @override
  String get profileCurrency => 'العملة';

  @override
  String get profileDefaultCustomer => 'العميل الافتراضي';

  @override
  String get warehouseNotAssignedBanner =>
      'لم يتم تعيين مستودع لحسابك. اختر مستودعاً قياسياً للمتابعة.';

  @override
  String get selectWarehouse => 'اختيار المستودع';

  @override
  String get selectWarehouseHint => 'اختر المستودع القياسي الذي ستعمل عليه';

  @override
  String get searchWarehouses => 'بحث في المستودعات';

  @override
  String get noWarehouses => 'لا توجد مستودعات قياسية متاحة لهذه الشركة';

  @override
  String get errorWarehousesLoadFailed =>
      'تعذر تحميل المستودعات، حاول مرة أخرى';

  @override
  String get warehouseSelected => 'تم تحديد المستودع';

  @override
  String get changeWarehouse => 'تغيير المستودع';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get oldPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get errorPasswordMismatch =>
      'كلمة المرور الجديدة وتأكيدها غير متطابقين';

  @override
  String get errorPasswordSameAsOld =>
      'يجب أن تختلف كلمة المرور الجديدة عن الحالية';

  @override
  String get passwordChanged => 'تم تغيير كلمة المرور';

  @override
  String get errorTimeout => 'انتهت مهلة الطلب';

  @override
  String get errorSessionExpired => 'انتهت الجلسة — يرجى تسجيل الدخول مجدداً';

  @override
  String get errorDynamicsUnavailable =>
      'بيئة Dynamics غير متاحة — أعد المحاولة لاحقاً';

  @override
  String get errorValidation => 'يرجى التحقق من المدخلات';

  @override
  String get errorCache => 'تعذر قراءة البيانات المحلية';

  @override
  String get errorMissingOrder => 'الأمر غير موجود';

  @override
  String get errorMissingSession => 'الجلسة غير موجودة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get close => 'إغلاق';

  @override
  String get save => 'حفظ';

  @override
  String get search => 'بحث';

  @override
  String get refresh => 'تحديث';

  @override
  String get details => 'التفاصيل';

  @override
  String get back => 'رجوع';

  @override
  String get continueLabel => 'متابعة';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';
}

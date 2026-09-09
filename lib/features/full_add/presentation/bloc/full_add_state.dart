part of 'full_add_bloc.dart';

enum FullAddValidation {
  none,
  barcodeRequired,
  noPrice,
  noStock,
  qtyInvalid,
  qtyExceeds,
  lookupRequired,
}

class FullAddState extends Equatable {
  const FullAddState({
    required this.order,
    this.cart = const <FullCartItemEntity>[],
    this.barcode = '',
    this.item,
    this.price,
    this.onHand,
    this.quantityText = '',
    this.lookingUp = false,
    this.fetchingPrice = false,
    this.fetchingQty = false,
    this.submitting = false,
    this.validation = FullAddValidation.none,
    this.failure,
    this.submitSucceeded = false,
    this.batchSucceeded = false,
    this.autoMode = true,
    this.lookupByItem = false,
  });

  final SalesOrderHeaderEntity order;
  final List<FullCartItemEntity> cart;
  final String barcode;
  final BarcodeItemEntity? item;
  final PriceInfoEntity? price;
  final WarehouseOnHandEntity? onHand;
  final String quantityText;
  final bool lookingUp;
  final bool fetchingPrice;
  final bool fetchingQty;
  final bool submitting;
  final FullAddValidation validation;
  final Failure? failure;
  final bool submitSucceeded;
  final bool batchSucceeded;

  /// When true, submit posts via `/lines/full`. When false, stages in cart.
  final bool autoMode;

  /// When true, lookup uses `GET /items/{itemNumber}` instead of barcodes.
  final bool lookupByItem;

  bool get hasPendingManual =>
      cart.any((FullCartItemEntity row) => !row.posted);

  FullAddState copyWith({
    SalesOrderHeaderEntity? order,
    List<FullCartItemEntity>? cart,
    String? barcode,
    BarcodeItemEntity? item,
    PriceInfoEntity? price,
    WarehouseOnHandEntity? onHand,
    String? quantityText,
    bool? lookingUp,
    bool? fetchingPrice,
    bool? fetchingQty,
    bool? submitting,
    FullAddValidation? validation,
    Failure? failure,
    bool? submitSucceeded,
    bool? batchSucceeded,
    bool? autoMode,
    bool? lookupByItem,
    bool clearItem = false,
    bool clearPrice = false,
    bool clearOnHand = false,
    bool clearError = false,
  }) {
    return FullAddState(
      order: order ?? this.order,
      cart: cart ?? this.cart,
      barcode: barcode ?? this.barcode,
      item: clearItem ? null : (item ?? this.item),
      price: clearPrice ? null : (price ?? this.price),
      onHand: clearOnHand ? null : (onHand ?? this.onHand),
      quantityText: quantityText ?? this.quantityText,
      lookingUp: lookingUp ?? this.lookingUp,
      fetchingPrice: fetchingPrice ?? this.fetchingPrice,
      fetchingQty: fetchingQty ?? this.fetchingQty,
      submitting: submitting ?? this.submitting,
      validation: validation ?? this.validation,
      failure: clearError ? null : (failure ?? this.failure),
      submitSucceeded: submitSucceeded ?? this.submitSucceeded,
      batchSucceeded: batchSucceeded ?? this.batchSucceeded,
      autoMode: autoMode ?? this.autoMode,
      lookupByItem: lookupByItem ?? this.lookupByItem,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    order,
    cart,
    barcode,
    item,
    price,
    onHand,
    quantityText,
    lookingUp,
    fetchingPrice,
    fetchingQty,
    submitting,
    validation,
    failure,
    submitSucceeded,
    batchSucceeded,
    autoMode,
    lookupByItem,
  ];
}

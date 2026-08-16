part of 'quick_add_bloc.dart';

enum QuickAddValidation {
  none,
  barcodeRequired,
  qtyInvalid,
  maxLines,
  emptyCart,
}

class QuickAddState extends Equatable {
  const QuickAddState({
    required this.order,
    this.lines = const <QuickCartLineEntity>[],
    this.barcode = '',
    this.quantityText = '1',
    this.submitting = false,
    this.validation = QuickAddValidation.none,
    this.failure,
    this.lastResult,
    this.lineAdded = false,
  });

  final SalesOrderHeaderEntity order;
  final List<QuickCartLineEntity> lines;
  final String barcode;
  final String quantityText;
  final bool submitting;
  final QuickAddValidation validation;
  final Failure? failure;
  final LineSubmitResultEntity? lastResult;
  final bool lineAdded;

  QuickAddState copyWith({
    SalesOrderHeaderEntity? order,
    List<QuickCartLineEntity>? lines,
    String? barcode,
    String? quantityText,
    bool? submitting,
    QuickAddValidation? validation,
    Failure? failure,
    LineSubmitResultEntity? lastResult,
    bool? lineAdded,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return QuickAddState(
      order: order ?? this.order,
      lines: lines ?? this.lines,
      barcode: barcode ?? this.barcode,
      quantityText: quantityText ?? this.quantityText,
      submitting: submitting ?? this.submitting,
      validation: validation ?? this.validation,
      failure: clearError ? null : (failure ?? this.failure),
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
      lineAdded: lineAdded ?? this.lineAdded,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    order,
    lines,
    barcode,
    quantityText,
    submitting,
    validation,
    failure,
    lastResult,
    lineAdded,
  ];
}

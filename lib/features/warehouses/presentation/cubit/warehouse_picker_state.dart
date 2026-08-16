part of 'warehouse_picker_cubit.dart';

sealed class WarehousePickerState extends Equatable {
  const WarehousePickerState();

  @override
  List<Object?> get props => <Object?>[];
}

final class WarehousePickerLoading extends WarehousePickerState {
  const WarehousePickerLoading();
}

final class WarehousePickerFailure extends WarehousePickerState {
  const WarehousePickerFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}

final class WarehousePickerLoaded extends WarehousePickerState {
  const WarehousePickerLoaded({
    required this.warehouses,
    this.saving = false,
    this.saveFailure,
  });

  final List<WarehouseEntity> warehouses;
  final bool saving;
  final Failure? saveFailure;

  WarehousePickerLoaded copyWith({bool? saving, Failure? saveFailure}) {
    return WarehousePickerLoaded(
      warehouses: warehouses,
      saving: saving ?? this.saving,
      saveFailure: saveFailure,
    );
  }

  @override
  List<Object?> get props => <Object?>[warehouses, saving, saveFailure];
}

/// Warehouse persisted in the cached session; navigation can continue.
final class WarehousePickerSaved extends WarehousePickerState {
  const WarehousePickerSaved(this.session);

  final UserSessionEntity session;

  @override
  List<Object?> get props => <Object?>[session];
}

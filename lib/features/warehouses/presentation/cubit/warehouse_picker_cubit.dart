import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_session_entity.dart';
import '../../../auth/domain/usecases/select_warehouse_usecase.dart';
import '../../domain/entities/warehouse_entity.dart';
import '../../domain/usecases/get_warehouses_usecase.dart';

part 'warehouse_picker_state.dart';

/// Loads Standard warehouses for the operating company and persists the pick.
class WarehousePickerCubit extends Cubit<WarehousePickerState> {
  WarehousePickerCubit({
    required GetWarehousesUseCase getWarehousesUseCase,
    required SelectWarehouseUseCase selectWarehouseUseCase,
  }) : _getWarehousesUseCase = getWarehousesUseCase,
       _selectWarehouseUseCase = selectWarehouseUseCase,
       super(const WarehousePickerLoading());

  final GetWarehousesUseCase _getWarehousesUseCase;
  final SelectWarehouseUseCase _selectWarehouseUseCase;

  Future<void> load(String company) async {
    emit(const WarehousePickerLoading());
    final Either<Failure, List<WarehouseEntity>> result =
        await _getWarehousesUseCase(company);
    result.fold(
      (Failure f) => emit(WarehousePickerFailure(f)),
      (List<WarehouseEntity> warehouses) =>
          emit(WarehousePickerLoaded(warehouses: warehouses)),
    );
  }

  Future<void> select(WarehouseEntity warehouse) async {
    final WarehousePickerState current = state;
    if (current is! WarehousePickerLoaded || current.saving) {
      return;
    }
    emit(current.copyWith(saving: true));
    final Either<Failure, UserSessionEntity> result =
        await _selectWarehouseUseCase(
          inventLocationId: warehouse.inventLocationId,
          dataAreaId: warehouse.dataAreaId,
        );
    result.fold(
      (Failure f) => emit(current.copyWith(saveFailure: f)),
      (UserSessionEntity session) => emit(WarehousePickerSaved(session)),
    );
  }
}

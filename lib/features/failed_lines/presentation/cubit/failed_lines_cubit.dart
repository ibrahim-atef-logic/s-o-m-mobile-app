import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../catalog/domain/entities/failed_line_entity.dart';
import '../../../catalog/domain/usecases/get_failed_lines_usecase.dart';

/// Loads failed line-job items for a sales order.
class FailedLinesCubit extends Cubit<FailedLinesState> {
  FailedLinesCubit({required GetFailedLinesUseCase getFailedLinesUseCase})
    : _getFailedLinesUseCase = getFailedLinesUseCase,
      super(const FailedLinesInitial());

  final GetFailedLinesUseCase _getFailedLinesUseCase;

  Future<void> load({
    required String salesId,
    required String company,
    String? mode,
  }) async {
    emit(const FailedLinesLoading());
    final Either<Failure, List<FailedLineEntity>> result =
        await _getFailedLinesUseCase(
          salesId: salesId,
          company: company,
          mode: mode,
        );
    result.fold(
      (Failure f) => emit(FailedLinesFailure(f)),
      (List<FailedLineEntity> lines) => emit(FailedLinesLoaded(lines)),
    );
  }
}

sealed class FailedLinesState extends Equatable {
  const FailedLinesState();

  @override
  List<Object?> get props => <Object?>[];
}

final class FailedLinesInitial extends FailedLinesState {
  const FailedLinesInitial();
}

final class FailedLinesLoading extends FailedLinesState {
  const FailedLinesLoading();
}

final class FailedLinesLoaded extends FailedLinesState {
  const FailedLinesLoaded(this.lines);

  final List<FailedLineEntity> lines;

  @override
  List<Object?> get props => <Object?>[lines];
}

final class FailedLinesFailure extends FailedLinesState {
  const FailedLinesFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}

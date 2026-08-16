import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/change_password_usecase.dart';

part 'change_password_state.dart';

/// Submits change-password against the .NET API (JWT subject).
class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit(this._changePasswordUseCase)
    : super(const ChangePasswordInitial());

  final ChangePasswordUseCase _changePasswordUseCase;

  Future<void> submit({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    emit(const ChangePasswordSubmitting());
    final Either<Failure, String> result = await _changePasswordUseCase(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    result.fold(
      (Failure f) => emit(ChangePasswordFailure(f)),
      (String message) => emit(ChangePasswordSuccess(message)),
    );
  }
}

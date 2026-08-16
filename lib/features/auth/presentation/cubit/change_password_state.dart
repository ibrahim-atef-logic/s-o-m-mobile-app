part of 'change_password_cubit.dart';

sealed class ChangePasswordState extends Equatable {
  const ChangePasswordState();

  @override
  List<Object?> get props => <Object?>[];
}

final class ChangePasswordInitial extends ChangePasswordState {
  const ChangePasswordInitial();
}

final class ChangePasswordSubmitting extends ChangePasswordState {
  const ChangePasswordSubmitting();
}

final class ChangePasswordSuccess extends ChangePasswordState {
  const ChangePasswordSuccess(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

final class ChangePasswordFailure extends ChangePasswordState {
  const ChangePasswordFailure(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => <Object?>[failure];
}

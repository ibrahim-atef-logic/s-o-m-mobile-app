import '../../../../core/error/failures.dart';
import '../../../../core/l10n/failure_l10n.dart';
import '../../../../l10n/app_localizations.dart';
import 'bloc/full_add_bloc.dart';

/// User-facing lookup/scan error shown on the barcode field.
String? fullAddLookupErrorMessage({
  required AppLocalizations l10n,
  required FullAddState state,
}) {
  if (state.lookingUp) {
    return null;
  }
  if (state.validation == FullAddValidation.barcodeRequired) {
    return l10n.errorBarcodeRequired;
  }
  final Failure? failure = state.failure;
  if (failure == null || state.item != null) {
    return null;
  }
  return failure.localizedMessage(l10n);
}

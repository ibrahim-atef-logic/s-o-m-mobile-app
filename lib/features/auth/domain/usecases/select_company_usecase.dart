import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/company_entity.dart';
import '../entities/user_session_entity.dart';
import '../repositories/auth_repository.dart';

class SelectCompanyUseCase {
  const SelectCompanyUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserSessionEntity>> call({
    required UserSessionEntity session,
    required String companyCode,
  }) async {
    CompanyEntity? company;
    for (final CompanyEntity c in session.companies) {
      if (c.code == companyCode) {
        company = c;
        break;
      }
    }
    if (company == null) {
      return const Left<Failure, UserSessionEntity>(
        ValidationFailure('Company not allowed'),
      );
    }
    final Either<Failure, void> saved = await _repository
        .persistSelectedCompany(companyCode);
    return saved.fold(
      Left<Failure, UserSessionEntity>.new,
      (_) => Right<Failure, UserSessionEntity>(
        session.copyWith(selectedCompany: company),
      ),
    );
  }
}

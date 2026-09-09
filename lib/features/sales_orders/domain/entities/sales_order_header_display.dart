import '../../../auth/domain/entities/user_session_entity.dart';
import 'sales_order_header_entity.dart';

/// Human labels for SO summary rows — prefer API display fields over codes.
extension SalesOrderHeaderDisplay on SalesOrderHeaderEntity {
  String get resolvedCustomerLabel {
    return UserSessionEntity.firstNonEmpty(<String?>[
          custDisplayName,
          salesName,
          custAccount,
        ]) ??
        custAccount;
  }

  String get resolvedWarehouseLabel {
    return UserSessionEntity.firstNonEmpty(<String?>[
          inventLocationName,
          inventLocationId,
        ]) ??
        inventLocationId;
  }

  String get resolvedSalesStatusLabel {
    return UserSessionEntity.firstNonEmpty(<String?>[
          salesStatusLabel,
          salesStatus,
        ]) ??
        salesStatus;
  }

  String get resolvedDocumentStatusLabel {
    return UserSessionEntity.firstNonEmpty(<String?>[
          documentStatusLabel,
          documentStatus,
        ]) ??
        documentStatus;
  }
}

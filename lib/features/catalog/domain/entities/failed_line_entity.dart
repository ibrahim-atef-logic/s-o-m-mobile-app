import 'package:equatable/equatable.dart';

class FailedLineEntity extends Equatable {
  const FailedLineEntity({
    required this.id,
    required this.jobId,
    required this.quantity,
    required this.status,
    this.barcode,
    this.itemNumber,
    this.commentAr,
    this.commentEn,
    this.createdAt,
  });

  final String id;
  final String jobId;
  final String? barcode;
  final String? itemNumber;
  final num quantity;
  final String status;
  final String? commentAr;
  final String? commentEn;
  final String? createdAt;

  String commentForLocale(String localeCode) {
    if (localeCode.toLowerCase().startsWith('ar')) {
      return commentAr ?? commentEn ?? '';
    }
    return commentEn ?? commentAr ?? '';
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    jobId,
    barcode,
    itemNumber,
    quantity,
    status,
    commentAr,
    commentEn,
    createdAt,
  ];
}

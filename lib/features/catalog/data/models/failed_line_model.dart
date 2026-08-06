import '../../../../core/utils/json_string.dart';
import '../../domain/entities/failed_line_entity.dart';

class FailedLineModel {
  const FailedLineModel({
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

  factory FailedLineModel.fromJson(Map<String, dynamic> json) {
    return FailedLineModel(
      id: json['id'] as String? ?? '',
      jobId: json['jobId'] as String? ?? '',
      barcode: json['barcode'] as String?,
      itemNumber: JsonString.trimOrNull(json['itemNumber']),
      quantity: json['quantity'] as num? ?? 0,
      status: json['status'] as String? ?? '',
      commentAr: json['commentAr'] as String?,
      commentEn: json['commentEn'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  FailedLineEntity toEntity() => FailedLineEntity(
    id: id,
    jobId: jobId,
    barcode: barcode,
    itemNumber: itemNumber,
    quantity: quantity,
    status: status,
    commentAr: commentAr,
    commentEn: commentEn,
    createdAt: createdAt,
  );
}

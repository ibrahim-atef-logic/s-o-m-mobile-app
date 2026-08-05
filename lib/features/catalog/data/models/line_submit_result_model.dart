import '../../domain/entities/line_submit_result_entity.dart';
import 'line_item_result_model.dart';

class LineSubmitResultModel {
  const LineSubmitResultModel({
    required this.success,
    this.jobId,
    this.item,
    this.items = const <LineItemResultModel>[],
    this.isFailed = false,
  });

  final bool success;
  final String? jobId;
  final LineItemResultModel? item;
  final List<LineItemResultModel> items;
  final bool isFailed;

  factory LineSubmitResultModel.fromJson(Map<String, dynamic> json) {
    final Object? rawItem = json['item'];
    final Object? rawItems = json['items'];
    return LineSubmitResultModel(
      success: json['success'] as bool? ?? false,
      jobId: json['jobId'] as String?,
      item: rawItem is Map<String, dynamic>
          ? LineItemResultModel.fromJson(rawItem)
          : null,
      items: rawItems is List<dynamic>
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(LineItemResultModel.fromJson)
                .toList()
          : const <LineItemResultModel>[],
      isFailed: json['isFailed'] as bool? ?? false,
    );
  }

  LineSubmitResultEntity toEntity() => LineSubmitResultEntity(
    success: success,
    jobId: jobId,
    item: item?.toEntity(),
    items: items.map((LineItemResultModel e) => e.toEntity()).toList(),
    isFailed: isFailed,
  );
}

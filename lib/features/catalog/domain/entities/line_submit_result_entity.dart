import 'package:equatable/equatable.dart';

import 'line_item_result_entity.dart';

class LineSubmitResultEntity extends Equatable {
  const LineSubmitResultEntity({
    required this.success,
    this.jobId,
    this.item,
    this.items = const <LineItemResultEntity>[],
    this.isFailed = false,
  });

  final bool success;
  final String? jobId;
  final LineItemResultEntity? item;
  final List<LineItemResultEntity> items;
  final bool isFailed;

  @override
  List<Object?> get props => <Object?>[success, jobId, item, items, isFailed];
}

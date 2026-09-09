import 'package:flutter/material.dart';

/// Forces LTR for codes (ItemId / barcode) so RTL UI does not reverse `.|022`.
class LtrText extends StatelessWidget {
  const LtrText(
    this.data, {
    this.style,
    this.maxLines,
    this.overflow,
    super.key,
  });

  final String data;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(
        data,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: maxLines != 1,
        textAlign: TextAlign.start,
      ),
    );
  }
}

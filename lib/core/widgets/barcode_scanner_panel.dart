import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/app_localizations.dart';
import '../extensions/theme_context.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_gradients.dart';

typedef BarcodeCaptured = void Function(String code);

/// Camera barcode scanner with reticle, torch, and last-scanned strip.
class BarcodeScannerPanel extends StatefulWidget {
  const BarcodeScannerPanel({
    required this.onCaptured,
    this.enabled = true,
    this.lastScanned,
    super.key,
  });

  final BarcodeCaptured onCaptured;
  final bool enabled;
  final String? lastScanned;

  @override
  State<BarcodeScannerPanel> createState() => _BarcodeScannerPanelState();
}

class _BarcodeScannerPanelState extends State<BarcodeScannerPanel>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    torchEnabled: false,
  );
  bool _handled = false;
  late final AnimationController _scanLine;

  @override
  void initState() {
    super.initState();
    _scanLine = AnimationController(
      vsync: this,
      duration: AppDimensions.durationScanLoop,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLine.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BarcodeScannerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastScanned != oldWidget.lastScanned) {
      _handled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (!widget.enabled) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.scanWithCamera,
                style: context.textTheme.titleMedium,
              ),
            ),
            Semantics(
              label: l10n.toggleTorch,
              button: true,
              child: IconButton(
                tooltip: l10n.toggleTorch,
                onPressed: () => _controller.toggleTorch(),
                icon: const Icon(Icons.flash_on_outlined),
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceSm),
        Container(
          height: AppDimensions.scannerViewportHeight + AppDimensions.spaceSm,
          padding: const EdgeInsets.all(AppDimensions.spaceXs),
          decoration: BoxDecoration(
            gradient: AppGradients.brand,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                MobileScanner(controller: _controller, onDetect: _onDetect),
                CustomPaint(painter: _ReticlePainter()),
                AnimatedBuilder(
                  animation: _scanLine,
                  builder: (BuildContext context, Widget? child) {
                    return Align(
                      alignment: Alignment(0, -0.7 + (_scanLine.value * 1.4)),
                      child: child,
                    );
                  },
                  child: Container(
                    height: AppDimensions.scanLineThickness,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceXl,
                    ),
                    color: AppColors.accent.withValues(
                      alpha: AppDimensions.scanLineAlpha,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.lastScanned != null &&
            widget.lastScanned!.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppDimensions.spaceSm),
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: BoxDecoration(
              color: AppColors.successContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.check_circle_outline,
                  size: AppDimensions.iconSm,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppDimensions.spaceXs),
                Expanded(
                  child: Text(
                    '${l10n.lastScanned}: ${widget.lastScanned}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.onSuccessContainer,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final List<Barcode> codes = capture.barcodes;
    if (codes.isEmpty) return;
    final String? raw = codes.first.rawValue;
    if (raw == null || raw.isEmpty) return;
    _handled = true;
    HapticFeedback.mediumImpact();
    widget.onCaptured(raw);
  }
}

class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = AppDimensions.reticleStroke
      ..style = PaintingStyle.stroke;
    const double len = AppDimensions.reticleArm;
    const double inset = AppDimensions.reticleInset;
    final Path path = Path()
      ..moveTo(inset, inset + len)
      ..lineTo(inset, inset)
      ..lineTo(inset + len, inset)
      ..moveTo(size.width - inset - len, inset)
      ..lineTo(size.width - inset, inset)
      ..lineTo(size.width - inset, inset + len)
      ..moveTo(inset, size.height - inset - len)
      ..lineTo(inset, size.height - inset)
      ..lineTo(inset + len, size.height - inset)
      ..moveTo(size.width - inset - len, size.height - inset)
      ..lineTo(size.width - inset, size.height - inset)
      ..lineTo(size.width - inset, size.height - inset - len);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../locale/locale_cubit.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';

/// Segmented Arabic / English language control.
class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale current = context.watch<LocaleCubit>().state;

    if (compact) {
      return PopupMenuButton<String>(
        tooltip: l10n.language,
        icon: const Icon(Icons.language),
        onSelected: (String code) {
          context.read<LocaleCubit>().setLanguageCode(code);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(value: 'ar', child: Text(l10n.arabic)),
          PopupMenuItem<String>(value: 'en', child: Text(l10n.english)),
        ],
      );
    }

    return Semantics(
      label: l10n.language,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(AppDimensions.space2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Segment(
              label: l10n.arabic,
              selected: current.languageCode == 'ar',
              onTap: () => context.read<LocaleCubit>().setLanguageCode('ar'),
            ),
            _Segment(
              label: l10n.english,
              selected: current.languageCode == 'en',
              onTap: () => context.read<LocaleCubit>().setLanguageCode('en'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMd,
            vertical: AppDimensions.spaceSm,
          ),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: selected ? AppColors.textInverse : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

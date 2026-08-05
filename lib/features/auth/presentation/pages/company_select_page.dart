import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/skeletons/company_tile_skeleton.dart';
import '../../../../core/widgets/skeletons/list_skeleton.dart';
import '../../../../core/widgets/states/app_empty_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/company_entity.dart';
import '../bloc/auth_bloc.dart';

class CompanySelectPage extends StatefulWidget {
  const CompanySelectPage({super.key});

  @override
  State<CompanySelectPage> createState() => _CompanySelectPageState();
}

class _CompanySelectPageState extends State<CompanySelectPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.selectCompany)),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (BuildContext context, AuthState state) {
          if (state is! AuthAuthenticated) {
            return ListSkeleton(
              itemCount: 4,
              itemBuilder: (_, int index) => const CompanyTileSkeleton(),
            );
          }
          final List<CompanyEntity> companies = state.session.companies;
          if (companies.isEmpty) {
            return AppEmptyView(
              title: l10n.noCompanies,
              icon: Icons.business_outlined,
            );
          }
          final List<CompanyEntity> filtered = companies.where((
            CompanyEntity c,
          ) {
            if (_query.isEmpty) return true;
            final String q = _query.toLowerCase();
            return c.name.toLowerCase().contains(q) ||
                c.code.toLowerCase().contains(q);
          }).toList();
          return Column(
            children: <Widget>[
              if (companies.length > 6)
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spaceMd),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: l10n.searchCompanies,
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (String v) => setState(() => _query = v),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spaceMd),
                  child: Text(
                    l10n.selectCompanyHint,
                    style: AppTextStyles.bodySm,
                  ),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? AppEmptyView(title: l10n.noCompanies)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceMd,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (BuildContext context, int index) {
                          final CompanyEntity company = filtered[index];
                          return AppCard(
                            onTap: () {
                              context.read<AuthBloc>().add(
                                AuthCompanySelected(company.code),
                              );
                            },
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        company.name,
                                        style: AppTextStyles.titleMd,
                                      ),
                                      const SizedBox(
                                        height: AppDimensions.spaceXs,
                                      ),
                                      Text(
                                        company.code,
                                        style: AppTextStyles.bodySm,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppColors.textTertiary,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

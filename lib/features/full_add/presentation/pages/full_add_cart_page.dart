import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/states/app_empty_view.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/full_cart_item_entity.dart';
import '../bloc/full_add_bloc.dart';

class FullAddCartPage extends StatelessWidget {
  const FullAddCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fullAdd),
      ),
      body: BlocBuilder<FullAddBloc, FullAddState>(
        builder: (BuildContext context, FullAddState state) {
          if (state.cart.isEmpty) {
            return AppEmptyView(
              title: l10n.cartEmpty,
              icon: Icons.shopping_cart_outlined,
              actionLabel: l10n.addItem,
              onAction: () => _openScan(context),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.spaceMd),
            itemCount: state.cart.length,
            itemBuilder: (BuildContext context, int index) {
              final FullCartItemEntity item = state.cart[index];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${item.itemNumber} · ${item.productName}',
                      style: AppTextStyles.titleMd,
                    ),
                    const SizedBox(height: AppDimensions.spaceSm),
                    Text(
                      '${l10n.barcode}: ${item.barcode}',
                      style: AppTextStyles.bodySm,
                    ),
                    Text(
                      '${l10n.quantity}: ${AppFormat.quantity(item.quantity)}',
                      style: AppTextStyles.numeric,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openScan(context),
        icon: const Icon(Icons.qr_code_scanner),
        label: Text(l10n.addItem),
      ),
    );
  }

  void _openScan(BuildContext context) {
    final FullAddBloc bloc = context.read<FullAddBloc>();
    bloc.add(const FullAddScanReset());
    context.push(
      '/orders/${bloc.state.order.salesId}/full-add/scan',
      extra: bloc,
    );
  }
}

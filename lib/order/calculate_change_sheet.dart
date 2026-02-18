import 'package:flutter/material.dart';
import 'package:ordermate/components/action_button.dart';
import 'package:ordermate/components/numpad.dart';
import 'package:ordermate/utils/constants.dart';
import 'package:ordermate/utils/extensions.dart';
import 'package:ordermate/utils/semantics_ids.dart';

class CalculateChangeSheet extends StatelessWidget {
  CalculateChangeSheet({required this.orderName, required this.sum, super.key});

  final String orderName;
  final double sum;
  final _givenSumNotifier = ValueNotifier<double>(0);
  final _changeNotifier = ValueNotifier<double>(0);

  static Future<bool?> show(
    BuildContext context, {
    required String orderName,
    required double sum,
  }) async {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppConstants.scaffoldBackground,
      builder: (context) =>
          CalculateChangeSheet(orderName: orderName, sum: sum),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          identifier: AppSemanticsIds.changeSheetTotalTitle,
          child: Text(
            context.translate.totalSum.toUpperCase(),
            style: TextStyle(color: Colors.black.withAlpha(175), fontSize: 12),
          ),
        ),
        Text(
          '${sum.toStringAsFixed(2)}€',
          style: TextStyle(fontSize: 46, fontWeight: .bold),
        ),
        SizedBox(height: AppConstants.spacingXL),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingXXL,
          ),
          child: _SectionedBox(
            start: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
              ),
              child: Column(
                mainAxisAlignment: .center,
                crossAxisAlignment: .start,
                children: [
                  Text(
                    context.translate.given,
                    style: TextStyle(color: Colors.black.withAlpha(175)),
                  ),
                  SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    scrollDirection: .horizontal,
                    child: ValueListenableBuilder(
                      valueListenable: _givenSumNotifier,
                      builder: (context, givenSum, _) {
                        return Text(
                          '${givenSum.toStringAsFixed(2)}€',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.green,
                            fontWeight: .bold,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            end: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingM,
              ),
              child: Column(
                mainAxisAlignment: .center,
                crossAxisAlignment: .end,
                children: [
                  Text(
                    context.translate.change,
                    style: TextStyle(color: Colors.black.withAlpha(175)),
                  ),
                  SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    scrollDirection: .horizontal,
                    child: ValueListenableBuilder(
                      valueListenable: _changeNotifier,
                      builder: (context, change, _) {
                        return Text(
                          '${change == 0 ? '-,--' : change.toStringAsFixed(2)}€',
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.redAccent,
                            fontWeight: .bold,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: AppConstants.spacingXXL),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingXXL - AppConstants.spacingXS * 2,
            ),
            child: ValueListenableBuilder(
              valueListenable: _givenSumNotifier,
              builder: (context, given, _) {
                return Numpad(
                  onValueChanged: setGivenValue,
                  currentValue: given,
                );
              },
            ),
          ),
        ),
        SizedBox(height: AppConstants.spacingM),
        _QuickOptionsRow(sum: sum, onSelected: setGivenValue),
        SizedBox(height: AppConstants.spacingXXL),
        ActionButton(
          semanticsIdentifier: AppSemanticsIds.changeSheetCancelButton,
          color: AppConstants.defaultAction,
          height: AppConstants.buttonHeightStandard,
          useSafeArea: false,
          onPressed: () => Navigator.pop(context, false),
          child: ActionButtonContent(
            icon: Icons.cancel_outlined,
            label: context.translate.cancel,
            color: DefaultTextStyle.of(context).style.color ?? Colors.black,
          ),
        ),
        ActionButton(
          color: AppConstants.emeraldAction,
          height: AppConstants.buttonHeightSum,
          useSafeArea: false,
          onPressed: () => Navigator.pop(context, true),
          child: ActionButtonContent(
            icon: Icons.payments_outlined,
            label: context.translate.finishOrder,
            color: AppConstants.emeraldAction,
          ),
        ),
        SizedBox(height: MediaQuery.viewPaddingOf(context).bottom),
      ],
    );
  }

  void setGivenValue(double given) {
    _givenSumNotifier.value = given;
    _changeNotifier.value = _calculateChange();
  }

  double _calculateChange() {
    final given = _givenSumNotifier.value;

    if (given <= sum) return 0;

    return given - sum;
  }
}

class _SectionedBox extends StatelessWidget {
  const _SectionedBox({required this.start, required this.end});

  final Widget start;
  final Widget end;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppConstants.borderRadiusXXL,
        border: Border.all(width: AppConstants.borderWidth, color: Colors.grey),
        color: Colors.white,
      ),
      child: SizedBox(
        height: 100,
        child: Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: start,
              ),
            ),
            VerticalDivider(
              indent: AppConstants.spacingXXL,
              endIndent: AppConstants.spacingXXL,
            ),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickOptionsRow extends StatelessWidget {
  const _QuickOptionsRow({required this.sum, this.onSelected});

  final double sum;
  final void Function(double)? onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXXL),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          for (final amount in sum.likelyCashPayments)
            ActionButton(
              semanticsIdentifier: AppSemanticsIds.changeSheetQuickOption(
                amount,
              ),
              useSafeArea: false,
              margin: EdgeInsets.symmetric(horizontal: AppConstants.spacingXS),
              padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
              height: AppConstants.buttonHeightCompact,
              color: Theme.of(context).colorScheme.primary,
              onPressed: () => onSelected?.call(amount),
              child: Center(child: Text('${amount.toStringAsFixed(2)}€')),
            ),
        ],
      ),
    );
  }
}

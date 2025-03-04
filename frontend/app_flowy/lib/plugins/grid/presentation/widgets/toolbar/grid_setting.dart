import 'package:app_flowy/plugins/grid/application/setting/setting_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flowy_infra/image.dart';
import 'package:flowy_infra_ui/style_widget/button.dart';
import 'package:flowy_infra_ui/style_widget/scrolling/styled_list.dart';
import 'package:flowy_infra_ui/style_widget/text.dart';
import 'package:flowy_infra_ui/widget/spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_flowy/generated/locale_keys.g.dart';
import '../../../application/field/field_controller.dart';
import '../../layout/sizes.dart';

class GridSettingContext {
  final String gridId;
  final GridFieldController fieldController;

  GridSettingContext({
    required this.gridId,
    required this.fieldController,
  });
}

class GridSettingList extends StatelessWidget {
  final GridSettingContext settingContext;
  final Function(GridSettingAction, GridSettingContext) onAction;
  const GridSettingList(
      {required this.settingContext, required this.onAction, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GridSettingBloc(gridId: settingContext.gridId),
      child: BlocListener<GridSettingBloc, GridSettingState>(
        listenWhen: (previous, current) =>
            previous.selectedAction != current.selectedAction,
        listener: (context, state) {
          state.selectedAction.foldLeft(null, (_, action) {
            onAction(action, settingContext);
          });
        },
        child: BlocBuilder<GridSettingBloc, GridSettingState>(
          builder: (context, state) {
            return _renderList();
          },
        ),
      ),
    );
  }

  String identifier() {
    return toString();
  }

  Widget _renderList() {
    final cells =
        GridSettingAction.values.where((value) => value.enable()).map((action) {
      return _SettingItem(action: action);
    }).toList();

    return SizedBox(
      width: 140,
      child: ListView.separated(
        shrinkWrap: true,
        controller: ScrollController(),
        itemCount: cells.length,
        separatorBuilder: (context, index) {
          return VSpace(GridSize.typeOptionSeparatorHeight);
        },
        physics: StyledScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return cells[index];
        },
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final GridSettingAction action;

  const _SettingItem({
    required this.action,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = context
        .read<GridSettingBloc>()
        .state
        .selectedAction
        .foldLeft(false, (_, selectedAction) => selectedAction == action);

    return SizedBox(
      height: GridSize.typeOptionItemHeight,
      child: FlowyButton(
        isSelected: isSelected,
        text: FlowyText.medium(
          action.title(),
          fontSize: 12,
          color: action.enable() ? null : Theme.of(context).disabledColor,
        ),
        onTap: () {
          context
              .read<GridSettingBloc>()
              .add(GridSettingEvent.performAction(action));
        },
        leftIcon: svgWidget(
          action.iconName(),
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

extension _GridSettingExtension on GridSettingAction {
  String iconName() {
    switch (this) {
      case GridSettingAction.filter:
        return 'grid/setting/filter';
      case GridSettingAction.sortBy:
        return 'grid/setting/sort';
      case GridSettingAction.properties:
        return 'grid/setting/properties';
    }
  }

  String title() {
    switch (this) {
      case GridSettingAction.filter:
        return LocaleKeys.grid_settings_filter.tr();
      case GridSettingAction.sortBy:
        return LocaleKeys.grid_settings_sortBy.tr();
      case GridSettingAction.properties:
        return LocaleKeys.grid_settings_Properties.tr();
    }
  }

  bool enable() {
    switch (this) {
      case GridSettingAction.properties:
        return true;
      default:
        return false;
    }
  }
}

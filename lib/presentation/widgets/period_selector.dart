import 'package:flutter/material.dart';

import '../providers/home_history_provider.dart';

/// A segmented button selector for history time periods.
class PeriodSelector extends StatelessWidget {
  final HistoryPeriod selected;
  final ValueChanged<HistoryPeriod> onChanged;

  const PeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<HistoryPeriod>(
      segments: HistoryPeriod.values
          .map((p) => ButtonSegment(
                value: p,
                label: Text(p.label),
              ))
          .toList(),
      selected: {selected},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          onChanged(selection.first);
        }
      },
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}

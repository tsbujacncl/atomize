import 'package:flutter/material.dart';

import '../../domain/models/timer_duration.dart';

/// A chip-based duration picker for timer settings.
///
/// Allows selecting from predefined duration options or using the default.
class DurationPicker extends StatelessWidget {
  /// Currently selected duration in seconds (null = use default).
  final int? selectedDuration;

  /// Called when a duration is selected.
  final ValueChanged<int?> onDurationChanged;

  /// Whether to show the "Default" option.
  final bool showDefaultOption;

  /// Label shown above the picker.
  final String? label;

  const DurationPicker({
    super.key,
    required this.selectedDuration,
    required this.onDurationChanged,
    this.showDefaultOption = true,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (showDefaultOption)
              _DurationChip(
                label: 'Default (${TimerDurationOption.twoMinutes.label})',
                isSelected: selectedDuration == null,
                onTap: () => onDurationChanged(null),
              ),
            for (final option in TimerDurationOption.values)
              _DurationChip(
                label: option.label,
                isSelected: selectedDuration == option.seconds,
                onTap: () => onDurationChanged(option.seconds),
              ),
          ],
        ),
      ],
    );
  }
}

/// Individual duration chip.
class _DurationChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

/// Compact duration selector shown as a dropdown button.
///
/// Use this when space is limited (e.g., in habit cards or forms).
class DurationDropdown extends StatelessWidget {
  /// Currently selected duration in seconds (null = use default).
  final int? selectedDuration;

  /// Called when a duration is selected.
  final ValueChanged<int?> onDurationChanged;

  const DurationDropdown({
    super.key,
    required this.selectedDuration,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentOption = TimerDurationOption.fromSeconds(selectedDuration);
    final displayText = selectedDuration == null
        ? 'Default (${TimerDurationOption.twoMinutes.label})'
        : currentOption.label;

    return PopupMenuButton<int?>(
      initialValue: selectedDuration,
      onSelected: onDurationChanged,
      tooltip: 'Select timer duration',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              displayText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<int?>(
          value: null,
          child: Text('Default (${TimerDurationOption.twoMinutes.label})'),
        ),
        const PopupMenuDivider(),
        for (final option in TimerDurationOption.values)
          PopupMenuItem<int?>(
            value: option.seconds,
            child: Text(option.label),
          ),
      ],
    );
  }
}

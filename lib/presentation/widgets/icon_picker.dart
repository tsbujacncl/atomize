import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/constants/habit_icons.dart';

/// Shows a modal bottom sheet for picking a habit icon.
///
/// Returns the selected icon ID, or null if cancelled.
Future<String?> showIconPicker(BuildContext context, {String? currentIconId}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _IconPickerSheet(currentIconId: currentIconId),
  );
}

class _IconPickerSheet extends StatelessWidget {
  final String? currentIconId;

  const _IconPickerSheet({this.currentIconId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Choose an Icon',
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  if (currentIconId != null)
                    TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text('Remove'),
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Icon grid
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: habitIconCategories.length,
                itemBuilder: (context, index) {
                  final category = habitIconCategories[index];
                  return _CategorySection(
                    category: category,
                    currentIconId: currentIconId,
                    onIconSelected: (iconId) => Navigator.pop(context, iconId),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategorySection extends StatelessWidget {
  final HabitIconCategory category;
  final String? currentIconId;
  final ValueChanged<String> onIconSelected;

  const _CategorySection({
    required this.category,
    this.currentIconId,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(
            category.name,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: category.icons.map((icon) {
            final isSelected = icon.id == currentIconId;
            return _IconButton(
              icon: icon,
              isSelected: isSelected,
              onTap: () => onIconSelected(icon.id),
            );
          }).toList(),
        ),
        const Gap(16),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final HabitIcon icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: icon.label,
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: theme.colorScheme.primary, width: 2)
                  : null,
            ),
            child: Icon(
              icon.icon,
              size: 28,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// A button that shows the current icon and opens the picker when tapped.
class IconPickerButton extends StatelessWidget {
  final String? iconId;
  final ValueChanged<String?> onChanged;

  const IconPickerButton({
    super.key,
    this.iconId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habitIcon = getHabitIconById(iconId);

    return InkWell(
      onTap: () async {
        final result = await showIconPicker(context, currentIconId: iconId);
        // result is null if user tapped "Remove" or dismissed
        // result is the icon ID if user selected an icon
        if (result != iconId) {
          onChanged(result);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: habitIcon != null
            ? Icon(
                habitIcon.icon,
                size: 32,
                color: theme.colorScheme.primary,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 24,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  Text(
                    'Icon',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

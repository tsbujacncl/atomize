import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/database/app_database.dart';
import '../../providers/auth_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../widgets/atomize_logo.dart';
import 'account_screen.dart';
import 'archived_habits_screen.dart';

/// Settings screen with app preferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(preferencesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (prefs) => _SettingsContent(prefs: prefs),
      ),
    );
  }
}

class _SettingsContent extends ConsumerWidget {
  final UserPreference? prefs;

  const _SettingsContent({required this.prefs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final isAnonymous = authService?.isAnonymous ?? true;
    final userEmail = authService?.userEmail;

    return ListView(
      children: [
        // Account Section
        _SectionHeader(title: 'Account'),
        _AccountCard(
          isAnonymous: isAnonymous,
          email: userEmail,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AccountScreen(),
              ),
            );
          },
        ),
        const Gap(8),
        // Archived Habits link
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: const Text('Archived Habits'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ArchivedHabitsScreen(),
                ),
              );
            },
          ),
        ),

        const Divider(height: 32),

        // Appearance Section
        _SectionHeader(title: 'Appearance'),
        _ThemeSelector(
          currentMode: prefs?.themeMode ?? 'system',
          onChanged: (mode) {
            ref.read(preferencesNotifierProvider.notifier).updateThemeMode(mode);
          },
        ),

        const Divider(height: 32),

        // Notifications Section
        _SectionHeader(title: 'Notifications'),
        _NotificationToggle(
          enabled: prefs?.notificationsEnabled ?? true,
          onChanged: (enabled) {
            ref
                .read(preferencesNotifierProvider.notifier)
                .setNotificationsEnabled(enabled);
          },
        ),
        if (prefs?.notificationsEnabled ?? true) ...[
          _QuietHoursSelector(
            startTime: prefs?.quietHoursStart ?? '22:00',
            endTime: prefs?.quietHoursEnd ?? '07:00',
            onChanged: (start, end) {
              ref
                  .read(preferencesNotifierProvider.notifier)
                  .updateQuietHours(start: start, end: end);
            },
          ),
          _ReminderOffsets(
            preMinutes: prefs?.preReminderMinutes ?? 30,
            postMinutes: prefs?.postReminderMinutes ?? 30,
            onPreChanged: (minutes) {
              ref
                  .read(preferencesNotifierProvider.notifier)
                  .updateReminderOffsets(preMinutes: minutes);
            },
            onPostChanged: (minutes) {
              ref
                  .read(preferencesNotifierProvider.notifier)
                  .updateReminderOffsets(postMinutes: minutes);
            },
          ),
        ],

        const Divider(height: 32),

        // Break Mode Section
        _SectionHeader(title: 'Taking a Break'),
        _BreakModeCard(
          breakModeUntil: prefs?.breakModeUntil,
          onSetBreak: (days) {
            final until = DateTime.now().add(Duration(days: days));
            ref.read(preferencesNotifierProvider.notifier).setBreakMode(until);
          },
          onCancelBreak: () {
            ref.read(preferencesNotifierProvider.notifier).setBreakMode(null);
          },
        ),

        const Divider(height: 32),

        // Support Section
        _SectionHeader(title: 'Support Atomize'),
        _SupportCard(),

        const Divider(height: 32),

        // About Section
        _SectionHeader(title: 'About'),
        _AboutCard(),

        const Gap(32),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final bool isAnonymous;
  final String? email;
  final VoidCallback onTap;

  const _AccountCard({
    required this.isAnonymous,
    this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isAnonymous
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAnonymous ? Icons.person_outline : Icons.person,
              color: isAnonymous
                  ? Theme.of(context).textTheme.bodySmall?.color
                  : Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(isAnonymous ? 'Guest Account' : 'Signed In'),
          subtitle: Text(
            isAnonymous
                ? 'Sign in to sync across devices'
                : email ?? 'Account linked',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isAnonymous)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              const Gap(8),
              const Icon(Icons.chevron_right),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  final String currentMode;
  final ValueChanged<String> onChanged;

  const _ThemeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            _ThemeOption(
              title: 'System',
              subtitle: 'Match device settings',
              icon: Icons.brightness_auto,
              isSelected: currentMode == 'system',
              onTap: () => onChanged('system'),
            ),
            const Divider(height: 1, indent: 56),
            _ThemeOption(
              title: 'Light',
              subtitle: 'Always use light theme',
              icon: Icons.light_mode,
              isSelected: currentMode == 'light',
              onTap: () => onChanged('light'),
            ),
            const Divider(height: 1, indent: 56),
            _ThemeOption(
              title: 'Dark',
              subtitle: 'Always use dark theme',
              icon: Icons.dark_mode,
              isSelected: currentMode == 'dark',
              onTap: () => onChanged('dark'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _NotificationToggle({
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        margin: EdgeInsets.zero,
        child: SwitchListTile(
          title: const Text('Enable Notifications'),
          subtitle: const Text('Receive habit reminders'),
          secondary: const Icon(Icons.notifications_outlined),
          value: enabled,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _QuietHoursSelector extends StatelessWidget {
  final String startTime;
  final String endTime;
  final Function(String start, String end) onChanged;

  const _QuietHoursSelector({
    required this.startTime,
    required this.endTime,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.bedtime_outlined, size: 20),
                  const Gap(12),
                  Text(
                    'Quiet Hours',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'No notifications during these hours',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            ListTile(
              title: const Text('Start'),
              trailing: Text(
                _formatTime(startTime),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () => _selectTime(context, true),
            ),
            const Divider(height: 1, indent: 16),
            ListTile(
              title: const Text('End'),
              trailing: Text(
                _formatTime(endTime),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () => _selectTime(context, false),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final currentTime = isStart ? startTime : endTime;
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final timeString =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (isStart) {
        onChanged(timeString, endTime);
      } else {
        onChanged(startTime, timeString);
      }
    }
  }
}

class _ReminderOffsets extends StatelessWidget {
  final int preMinutes;
  final int postMinutes;
  final ValueChanged<int> onPreChanged;
  final ValueChanged<int> onPostChanged;

  const _ReminderOffsets({
    required this.preMinutes,
    required this.postMinutes,
    required this.onPreChanged,
    required this.onPostChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.schedule_outlined, size: 20),
                  const Gap(12),
                  Text(
                    'Reminder Timing',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text('Pre-reminder'),
              subtitle: const Text('Minutes before scheduled time'),
              trailing: _MinutesPicker(
                value: preMinutes,
                onChanged: onPreChanged,
              ),
            ),
            const Divider(height: 1, indent: 16),
            ListTile(
              title: const Text('Post-reminder'),
              subtitle: const Text('Minutes after if not completed'),
              trailing: _MinutesPicker(
                value: postMinutes,
                onChanged: onPostChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MinutesPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _MinutesPicker({
    required this.value,
    required this.onChanged,
  });

  static const _options = [15, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: _options.contains(value) ? value : 30,
      underline: const SizedBox(),
      items: _options.map((minutes) {
        return DropdownMenuItem(
          value: minutes,
          child: Text('$minutes min'),
        );
      }).toList(),
      onChanged: (v) => v != null ? onChanged(v) : null,
    );
  }
}

class _BreakModeCard extends StatelessWidget {
  final DateTime? breakModeUntil;
  final ValueChanged<int> onSetBreak;
  final VoidCallback onCancelBreak;

  const _BreakModeCard({
    required this.breakModeUntil,
    required this.onSetBreak,
    required this.onCancelBreak,
  });

  @override
  Widget build(BuildContext context) {
    final isInBreakMode =
        breakModeUntil != null && breakModeUntil!.isAfter(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isInBreakMode ? Icons.pause_circle : Icons.beach_access,
                    size: 24,
                    color: isInBreakMode
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isInBreakMode ? 'Break Mode Active' : 'Take a Break',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Gap(4),
                        Text(
                          isInBreakMode
                              ? 'Until ${_formatDate(breakModeUntil!)}'
                              : 'Mute all notifications temporarily',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(16),
              if (isInBreakMode) ...[
                // Explanation of what break mode does
                Text(
                  '• Notifications paused',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Gap(4),
                Text(
                  '• Scores won\'t decay',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Gap(16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onCancelBreak,
                    child: const Text('End Break Early'),
                  ),
                ),
              ] else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your habits will still be here when you get back. '
                      'Scores may drop — that\'s normal.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Gap(12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _BreakButton(days: 3, onTap: () => onSetBreak(3)),
                        _BreakButton(days: 7, onTap: () => onSetBreak(7)),
                        _BreakButton(days: 14, onTap: () => onSetBreak(14)),
                        _BreakButton(days: 30, onTap: () => onSetBreak(30)),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _BreakButton extends StatelessWidget {
  final int days;
  final VoidCallback onTap;

  const _BreakButton({required this.days, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text('$days days'),
      onPressed: onTap,
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Atomize is free and always will be.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(8),
              Text(
                'No ads. No premium. Just habits. '
                'If it\'s helped you build better habits, consider supporting development.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Gap(16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _openBuyMeACoffee(),
                  icon: const Text('☕'),
                  label: const Text('Buy me a coffee'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openBuyMeACoffee() async {
    final uri = Uri.parse('https://buymeacoffee.com/tyrbujac');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: AtomizeLogo(fontSize: 28),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'Small habits. Big change.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
              ),
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Version'),
              trailing: Text(
                '1.2.0',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Developed by'),
              trailing: Text(
                'Tyr',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Open privacy policy
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy policy coming soon')),
                );
              },
            ),
            const Gap(8),
          ],
        ),
      ),
    );
  }
}

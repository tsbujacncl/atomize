# Atomize V1.2 - Implementation Plan

## Overview

This document tracks the development progress of Atomize V1.2, a complete redesign focusing on anti-addictive, supportive habit tracking with flame-based scoring.

**Last Updated**: 2025-11-25
**Current Version**: V1.2 Foundation (Milestones 0-7)
**Branch**: master
**Design Document**: [DESIGN_DOCUMENT_V1.2.md](./DESIGN_DOCUMENT_V1.2.md)

---

## Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| State Management | **Riverpod** | Code generation, type safety, testability |
| Database | **SQLite via Drift** | Relational data, complex queries, migrations |
| Old Code | **Deleted** | Clean slate for V1.2 philosophy |
| Approach | **Smaller milestones** | Incremental progress, easier testing |

---

## Completed Milestones

### ✅ Milestone 0: Project Reset
**Status**: Complete

- [x] Delete existing `lib/` folder contents
- [x] Update `pubspec.yaml` with new dependencies:
  - Removed: `hive`, `hive_flutter`, `fl_chart`, `percent_indicator`
  - Added: `drift`, `sqlite3_flutter_libs`, `path_provider`, `path`
  - Kept: `flutter_riverpod`, `flutter_local_notifications`, `google_fonts`, `uuid`, `intl`, `gap`
- [x] Run `flutter pub get`
- [x] Create basic folder structure
- [x] Create minimal `main.dart` that runs

**Files Created**:
- `lib/main.dart`
- `lib/app.dart`

---

### ✅ Milestone 1: Data Layer & Models
**Status**: Complete

- [x] Create SQLite database with Drift (`app_database.dart`)
- [x] Define `Habits` table (binary type only):
  - id, name, location, scheduledTime
  - score (0-100), maturity
  - quickWhy, feelingWhy, identityWhy, outcomeWhy
  - createdAt, isArchived, lastDecayAt
- [x] Define `HabitCompletions` table
- [x] Define `UserPreferences` table
- [x] Create DAOs for each table
- [x] Create repository classes wrapping DAOs
- [x] Create enums: `HabitType`, `CompletionSource`, `Weekday`
- [x] Run `dart run build_runner build` for Drift codegen

**Files Created**:
- `lib/data/database/app_database.dart` (+ generated `.g.dart`)
- `lib/data/database/tables/habits_table.dart`
- `lib/data/database/tables/completions_table.dart`
- `lib/data/database/tables/preferences_table.dart`
- `lib/data/database/daos/habit_dao.dart` (+ generated `.g.dart`)
- `lib/data/database/daos/completion_dao.dart` (+ generated `.g.dart`)
- `lib/data/database/daos/preferences_dao.dart` (+ generated `.g.dart`)
- `lib/data/repositories/habit_repository.dart`
- `lib/data/repositories/completion_repository.dart`
- `lib/data/repositories/preferences_repository.dart`
- `lib/domain/models/enums.dart`

---

### ✅ Milestone 2: Score System
**Status**: Complete

- [x] Create `ScoreService` class
- [x] Implement `calculateGain(currentScore)`:
  ```
  baseGain = 10 * pow(1 - currentScore / 100, 0.7)
  ```
- [x] Implement `calculateDecay(currentScore, maturity)`:
  ```
  baseDecay = (3 + score * 0.05) * (1 / (1 + maturity * 0.03))
  ```
- [x] Implement maturity tracking (increment when score > 50)
- [x] Create `applyCompletion()` method
- [x] Create `applyDayEndDecay()` method

**Files Created**:
- `lib/domain/services/score_service.dart`

**Score Examples** (from design doc):
| Current Score | Gain on Complete | Decay on Miss (maturity 0) |
|---------------|------------------|---------------------------|
| 0 | +10.0 | -3.0 |
| 30 | +8.1 | -4.5 |
| 50 | +6.5 | -5.5 |
| 70 | +4.6 | -6.5 |
| 90 | +2.2 | -7.5 |

---

### ✅ Milestone 3: Theme & Flame Widget
**Status**: Complete

- [x] Create `app_colors.dart` with palette:
  - Primary backgrounds (light/dark)
  - Text colors (primary/secondary/tertiary)
  - Accent (calm teal #4ECDC4)
  - Flame colors: Blue, Orange, Red, Gold, White
- [x] Create `app_theme.dart` (light + dark themes)
- [x] Create `FlameWidget`:
  - Score 0-30: Blue (#3B82F6)
  - Score 30-50: Blue→Orange gradient
  - Score 50-80: Orange (#F97316)
  - Score 80-95: Orange→Red gradient
  - Score 95-100: Red (#EF4444) with golden core (#FBBF24)
- [x] Add subtle flame animation (gentle flicker)
- [x] Create `FlameIndicator` for compact list display

**Files Created**:
- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_theme.dart`
- `lib/presentation/widgets/flame_widget.dart`

---

### ✅ Milestone 4: State Management (Riverpod)
**Status**: Complete

- [x] Create `database_provider.dart` (provides AppDatabase)
- [x] Create `repository_providers.dart`:
  - `habitRepositoryProvider`
  - `completionRepositoryProvider`
  - `preferencesRepositoryProvider`
- [x] Create `habit_provider.dart`:
  - `habitsStreamProvider` (reactive stream)
  - `habitByIdProvider` (family provider)
  - `habitNotifierProvider` (AsyncNotifier for CRUD)
- [x] Create `today_habits_provider.dart`:
  - `TodayHabit` class with completion status
  - `todayHabitsProvider` (sorted: incomplete first)
  - `effectiveDateProvider` (4am boundary)
- [x] Create `preferences_provider.dart`:
  - `preferencesStreamProvider`
  - `preferencesNotifierProvider`
  - `isOnboardingCompletedProvider`
  - `isInBreakModeProvider`
  - `currentThemeModeProvider`
- [x] Create `score_provider.dart`:
  - `scoreServiceProvider`
  - `completionNotifierProvider`

**Files Created**:
- `lib/presentation/providers/database_provider.dart`
- `lib/presentation/providers/repository_providers.dart`
- `lib/presentation/providers/habit_provider.dart`
- `lib/presentation/providers/today_habits_provider.dart`
- `lib/presentation/providers/preferences_provider.dart`
- `lib/presentation/providers/score_provider.dart`

---

### ✅ Milestone 5: Home Screen UI
**Status**: Complete

- [x] Create `HomeScreen` scaffold
- [x] Create `HabitCard` widget:
  - Rectangle layout (not grid)
  - Shows: name, scheduled time, flame, score %
  - Tap flame → complete habit
  - Tap card → expand/navigate to detail
- [x] Empty state: "No habits yet. Create your first one."
- [x] FAB or button to create habit
- [x] Integrate with `todayHabitsProvider`

**Files Created**:
- `lib/presentation/screens/home/home_screen.dart`
- `lib/presentation/widgets/habit_card.dart`
- `lib/presentation/screens/create_habit/create_habit_screen.dart` (placeholder)
- `lib/presentation/screens/habit_detail/habit_detail_screen.dart` (placeholder)
- `lib/presentation/screens/settings/settings_screen.dart` (placeholder)

---

### ✅ Milestone 5.1: Logo & Branding
**Status**: Complete

- [x] Create `AtomizeLogo` widget:
  - Gradient text from blue (#3B82F6) to orange (#F97316)
  - "At" + flame icon + "mize" layout
  - Inline flame replaces the "o" letter
  - Static (no animation)
  - Configurable font size
- [x] Update Home Screen with logo header:
  - Logo in app bar (24px)
  - "Today" as section header below
- [x] Create Onboarding Welcome Screen:
  - Large logo (48px)
  - Tagline: "Small habits. Big change."
  - Get Started button
- [x] Update DESIGN_DOCUMENT_V1.2.md with section 5.9 Logo & Branding

**Files Created/Modified**:
- `lib/presentation/widgets/atomize_logo.dart` (new)
- `lib/presentation/screens/home/home_screen.dart` (modified)
- `lib/presentation/screens/onboarding/welcome_screen.dart` (new)

---

### ✅ Milestone 6: Create Habit Screen
**Status**: Complete

- [x] Create `CreateHabitScreen`
- [x] Form fields:
  - What (habit name) — required
  - When (time picker) — required
  - Where (location) — optional
  - Why (single line purpose) — optional
- [x] Validation
- [x] Save to database via provider
- [x] Navigate back to home after save

**Files Modified**:
- `lib/presentation/screens/create_habit/create_habit_screen.dart` (implemented)

---

### ✅ Milestone 7: Habit Detail Screen
**Status**: Complete

- [x] Create `HabitDetailScreen`
- [x] Large flame visualization
- [x] Show: name, score, completion rate, purpose
- [x] Completion rate with time period selector (1M | 3M | 1Y | All)
- [x] Edit button → edit screen
- [x] Archive button (soft delete)
- [x] Delete button (with confirmation)

**Files Created/Modified**:
- `lib/presentation/screens/habit_detail/habit_detail_screen.dart` (implemented)
- `lib/presentation/screens/habit_detail/edit_habit_screen.dart` (new)
- `lib/presentation/providers/completion_stats_provider.dart` (new)
- `lib/data/repositories/completion_repository.dart` (updated)
- `lib/data/database/daos/completion_dao.dart` (updated)

---

## Pending Milestones

### ⏳ Milestone 8: Basic Notifications
**Status**: Pending

- [ ] Create `NotificationService`
- [ ] Initialize notifications in `main.dart`
- [ ] Schedule pre-reminder (30 min before habit time)
- [ ] Schedule post-reminder (30 min after if not completed)
- [ ] Add quiet hours logic (default 10pm-7am)
- [ ] Cancel notifications when habit completed

---

### ⏳ Milestone 9: Progress Bar Chart
**Status**: Pending

- [ ] Create simple bar chart widget (last 30 days)
- [ ] Each bar = score on that day
- [ ] Bar color matches flame color
- [ ] Show in habit detail screen
- [ ] Simple stats display

---

### ⏳ Milestone 10: Settings & Onboarding
**Status**: Pending

- [ ] Create `SettingsScreen`
- [ ] Create onboarding flow (3 screens)
- [ ] Track onboarding completion

---

### ⏳ Milestone 11: Grace Window & Day Boundary
**Status**: Pending

- [ ] Implement grace window logic (4am boundary)
- [ ] Apply decay at day boundary
- [ ] Handle timezone correctly

---

## Future Phases

### Phase 2: Enhanced Habits (V1.1)
- Count-type habits
- Weekly-type habits
- Purpose prompts (after 7 days)
- Habit stacking
- Smart habit templates

### Phase 3: Smart Features (V1.2)
- Notification style system (7 styles)
- Notification learning (ML-lite)
- History editing with credit percentages
- Weekly summary system
- Break mode
- Soft habit limits

### Phase 4: Sync & Polish (V1.3)
- Supabase setup
- Authentication
- Sync implementation
- Email weekly summaries
- Widgets (iOS/Android)
- Calendar integration
- Data export/deletion

### Phase 5: Platform Expansion (V1.4)
- Web version (PWA)
- iPad optimization
- Android tablet support

---

## Technical Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.9.2+ |
| State Management | flutter_riverpod 3.0.3 |
| Database | drift 2.22.1 + sqlite3_flutter_libs |
| Notifications | flutter_local_notifications 19.5.0 |
| Fonts | google_fonts 6.3.2 |
| Code Generation | build_runner, riverpod_generator, drift_dev |

---

## Changelog

### 2025-11-25
- **M7 Enhancement**: Replaced maturity display with completion rate + time period selector (1M | 3M | 1Y | All)
- **Milestone 7 Complete**: Habit Detail Screen - Large flame, stats, details, purpose display, edit/archive/delete functionality
- **Milestone 6 Complete**: Create Habit Screen - Full form with What/When/Where/Why fields, time picker, validation, and save functionality

### 2025-11-24
- **Milestone 5.1 Complete**: Logo & Branding - AtomizeLogo widget with blue→orange gradient and inline flame
- **Milestone 5 Complete**: Home screen UI with habit cards and empty state
- **V1.2 Fresh Start**: Complete redesign based on DESIGN_DOCUMENT_V1.2.md
- **Milestones 0-4 Complete**: Project reset, data layer, score system, theme, Riverpod providers
- **Philosophy Change**: Anti-addictive design, no streaks, no achievements, flame-based scoring
- **Architecture Change**: SQLite/Drift replaces Hive, manual Riverpod providers

---

**Document maintained by**: Development Team
**Review frequency**: After each milestone completion
**Related documents**:
- [DESIGN_DOCUMENT_V1.2.md](./DESIGN_DOCUMENT_V1.2.md) - Product vision and specifications

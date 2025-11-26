# Atomize V1.2 - Implementation Plan

## Overview

This document tracks the development progress of Atomize V1.2, a complete redesign focusing on anti-addictive, supportive habit tracking with flame-based scoring.

**Last Updated**: 2025-11-26
**Current Version**: V1.2 Foundation + Phase 2 + Auth + History (Milestones 0-17)
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

### ✅ Milestone 8: Basic Notifications
**Status**: Complete

- [x] Create `NotificationService`
- [x] Initialize notifications in `main.dart`
- [x] Schedule pre-reminder (30 min before habit time)
- [x] Schedule post-reminder (30 min after if not completed)
- [x] Add quiet hours logic (default 10pm-7am)
- [x] Cancel notifications when habit completed

**Files Created/Modified**:
- `lib/domain/services/notification_service.dart` (new)
- `lib/presentation/providers/notification_provider.dart` (new)
- `lib/presentation/providers/score_provider.dart` (updated - cancel on completion)
- `lib/main.dart` (updated - initialize notifications)

**Notes**:
- Notifications are skipped on web (not supported)
- Uses flutter_local_notifications + timezone packages
- Respects quiet hours, break mode, and notification settings from preferences

---

### ✅ Milestone 9: Progress Bar Chart

**Status**: Complete

- [x] Create simple bar chart widget (last 30 days)
- [x] Each bar = completion on that day
- [x] Bar color matches flame color based on current score
- [x] Show in habit detail screen
- [x] Simple stats display (X/30 days completed with percentage)

**Files Created/Modified**:
- `lib/presentation/widgets/progress_bar_chart.dart` (new)
- `lib/presentation/providers/completion_history_provider.dart` (new)
- `lib/presentation/screens/habit_detail/habit_detail_screen.dart` (updated)

---

### ✅ Milestone 10: Settings & Onboarding

**Status**: Complete

- [x] Create `SettingsScreen` with full functionality:
  - Theme selector (system/light/dark)
  - Notification toggle with quiet hours and reminder timing
  - Break mode (3/7/14/30 day options)
  - Support Atomize (Buy Me a Coffee link)
  - About section with logo, version, and privacy policy
- [x] Create onboarding flow (3 screens):
  - Welcome screen with logo and tagline
  - Create first habit screen
  - Tutorial screen (tap flame demo)
- [x] Track onboarding completion via preferences
- [x] Update app.dart to route based on onboarding status
- [x] Theme mode reactive to user preferences

**Files Created/Modified**:
- `lib/presentation/screens/settings/settings_screen.dart` (implemented)
- `lib/presentation/screens/onboarding/tutorial_screen.dart` (new)
- `lib/presentation/screens/onboarding/onboarding_flow.dart` (new)
- `lib/presentation/screens/create_habit/create_habit_screen.dart` (updated - callback support)
- `lib/app.dart` (updated - onboarding routing + theme)
- `pubspec.yaml` (added url_launcher)

---

### ✅ Milestone 11: Grace Window & Day Boundary

**Status**: Complete

- [x] Grace window logic (4am boundary) - already implemented in PreferencesRepository.getEffectiveDate()
- [x] Multi-day decay handling - ScoreService.applyDayEndDecay() now handles gaps when user doesn't open app for multiple days
- [x] Day boundary decay provider - dayBoundaryDecayProvider triggers on app start
- [x] App initialization integration - decay check runs automatically when returning users open app

**How it works:**
- `getEffectiveDate()` returns yesterday's date if current time is before 4am (day boundary)
- Users can complete habits until 4am the next day (grace window)
- When app opens, `dayBoundaryDecayProvider` checks all habits
- For each habit, iterates through days since `lastDecayAt` and applies decay for missed days
- Multi-day gaps are handled correctly (e.g., 5 days away = 5 decay events per incomplete habit)

**Files Modified:**
- `lib/domain/services/score_service.dart` - Updated applyDayEndDecay() for multi-day gaps
- `lib/presentation/providers/score_provider.dart` - Added dayBoundaryDecayProvider
- `lib/app.dart` - Integrated decay check on app start

---

### ✅ Milestone 12: Supabase Cloud Sync

**Status**: Complete

- [x] Add Supabase dependencies (supabase_flutter, connectivity_plus, flutter_secure_storage, flutter_dotenv)
- [x] Create .env file for credentials (gitignored)
- [x] Initialize Supabase in main.dart
- [x] Create AuthService with anonymous sign-in
- [x] Create ConnectivityService for online/offline detection
- [x] Create SyncService for local-first sync
- [x] Create LocalSyncQueue for offline operations
- [x] Integrate sync hooks into HabitRepository and CompletionRepository
- [x] Update app initialization flow with auth and sync
- [x] Create Supabase schema SQL file

**Architecture:**
- Local-first: SQLite/Drift remains source of truth for immediate UI
- Changes sync to Supabase in background
- App works fully offline, queues operations for later sync
- Anonymous auth auto-creates account on first launch
- Server-wins conflict resolution (simplest approach)

**Files Created:**
- `lib/core/config/supabase_config.dart` - Config from .env
- `lib/domain/services/auth_service.dart` - Anonymous/email auth
- `lib/domain/services/connectivity_service.dart` - Network monitoring
- `lib/domain/services/sync_service.dart` - Sync orchestration
- `lib/data/sync/sync_queue.dart` - Offline queue
- `lib/presentation/providers/supabase_provider.dart` - Supabase client provider
- `lib/presentation/providers/auth_provider.dart` - Auth state management
- `lib/presentation/providers/sync_provider.dart` - Sync state management
- `supabase/schema.sql` - Database schema for Supabase
- `.env` - Credentials (gitignored)
- `.env.example` - Template for credentials

**Files Modified:**
- `pubspec.yaml` - Added Supabase dependencies
- `lib/main.dart` - Initialize dotenv and Supabase
- `lib/app.dart` - Auth and sync initialization
- `lib/data/repositories/habit_repository.dart` - Sync hooks
- `lib/data/repositories/completion_repository.dart` - Sync hooks
- `lib/presentation/providers/repository_providers.dart` - Inject SyncService
- `.gitignore` - Added .env

---

### ✅ Milestone 13: Weekly Habits

**Status**: Complete

- [x] Add weekly type to habit type selector (binary/count/weekly)
- [x] Add weekly target field to create/edit screens (1-7 times per week)
- [x] Update TodayHabitsProvider to calculate weekly progress (distinct completed days)
- [x] Update HabitCard with weekly progress UI (progress ring with calendar icon)
- [x] Update completion/decay logic for weekly habits (decay only at end of week if target not met)
- [x] Update habit detail screen to show weekly target

**How Weekly Habits Work:**
- User sets a weekly target (e.g., "Exercise 3x per week")
- Progress shows completed days this week (e.g., "2/3")
- Can complete once per day, progress counts toward weekly goal
- Decay only applies at end of week if target wasn't met (not daily)
- Week starts on Monday, ends on Sunday

**Files Modified:**
- `lib/presentation/screens/create_habit/create_habit_screen.dart` - Weekly type + target
- `lib/presentation/screens/habit_detail/edit_habit_screen.dart` - Weekly target editing
- `lib/presentation/providers/habit_provider.dart` - weeklyTarget in updateHabit
- `lib/data/repositories/habit_repository.dart` - weeklyTarget persistence
- `lib/presentation/providers/today_habits_provider.dart` - Weekly progress calculation
- `lib/presentation/widgets/habit_card.dart` - Weekly progress/completed buttons
- `lib/domain/services/score_service.dart` - Weekly-aware decay logic
- `lib/presentation/screens/habit_detail/habit_detail_screen.dart` - Display weekly target

---

### ✅ Milestone 14: Purpose Prompts & Habit Stacking

**Status**: Complete

- [x] Purpose prompts (after 7 days):
  - Created `purpose_prompt_provider.dart` with providers to detect habits needing prompts
  - Habits 7+ days old without deep purpose fields trigger a prompt banner
  - Banner shows on home screen with "Deepen your [habit name]" CTA
  - Created `deep_purpose_screen.dart` - 3-step wizard for feelings/identity/outcomes
  - Each step has example chips for quick fill suggestions
  - Purpose section in habit detail screen shows Add/Edit button
- [x] Habit stacking:
  - Added `afterHabitId` support to create/update methods in repository and provider
  - Added `_HabitStackSelector` widget to create and edit habit screens
  - Bottom sheet picker shows all existing habits to stack after
  - "None (standalone habit)" option to remove stacking
  - Habit detail screen shows "After: [habit name]" in details section

**How Purpose Prompts Work:**
- After 7 days with a habit, if no deep purpose is set, a banner appears on home screen
- Tapping the banner opens a 3-step wizard (feelings, identity, outcomes)
- Users can tap example chips or type their own responses
- Saved purposes display in the habit detail screen

**How Habit Stacking Works:**
- When creating/editing a habit, select "Stack After" to link to another habit
- Creates a chain: "After I [habit A], I will [habit B]"
- Linked habit name displays in the details section of habit detail screen
- Can be cleared by selecting "None (standalone habit)"

**Files Created:**
- `lib/presentation/providers/purpose_prompt_provider.dart`
- `lib/presentation/screens/habit_detail/deep_purpose_screen.dart`

**Files Modified:**
- `lib/presentation/screens/home/home_screen.dart` - Purpose prompt banner
- `lib/presentation/screens/habit_detail/habit_detail_screen.dart` - Purpose edit, stacking display
- `lib/presentation/screens/create_habit/create_habit_screen.dart` - Habit stack selector
- `lib/presentation/screens/habit_detail/edit_habit_screen.dart` - Habit stack selector
- `lib/presentation/providers/habit_provider.dart` - afterHabitId support
- `lib/data/repositories/habit_repository.dart` - afterHabitId in create/update

---

### ✅ Milestone 15: Account & Authentication
**Status**: Complete

- [x] Add `sign_in_with_apple` and `google_sign_in` packages
- [x] Configure Google OAuth in Google Cloud Console (iOS + Web clients)
- [x] Configure Google provider in Supabase dashboard
- [x] Update `AuthService` with Apple and Google sign-in methods
- [x] Create `AccountScreen` with:
  - Account status card (Guest/Signed In)
  - Apple Sign-In button (iOS only)
  - Google Sign-In button
  - Email sign-up/sign-in form with toggle
  - Confirm password field for registration
  - Forgot password functionality
- [x] Add account section to Settings screen
- [x] Configure iOS `Info.plist` with Google Sign-In URL schemes
- [x] Fix platform detection for web compatibility (`kIsWeb` + `defaultTargetPlatform`)
- [x] Fix `isAnonymous` detection to check both flag and email presence

**Files Created:**
- `lib/presentation/screens/settings/account_screen.dart`
- `lib/presentation/providers/auth_provider.dart`

**Files Modified:**
- `lib/domain/services/auth_service.dart` - Apple/Google sign-in, password reset
- `lib/presentation/screens/settings/settings_screen.dart` - Account section
- `ios/Runner/Info.plist` - Google Sign-In configuration
- `pubspec.yaml` - Added sign_in_with_apple, google_sign_in packages

---

### ✅ Milestone 16: Smart Habit Reframing (Breaking Bad Habits)
**Status**: Complete

Atomize handles breaking bad habits through positive framing — no separate feature needed. This milestone adds a smart suggestion to help users reframe negative habits.

- [x] Detect trigger words in habit name field during creation
- [x] Show reframing suggestion banner when negative framing detected
- [x] Suggest specific positive reframes based on detected topic

**Trigger words:**
- Action: "stop", "quit", "reduce", "less", "avoid", "no more", "cut"
- Topics: "smoking", "alcohol", "drinking", "phone", "sugar", "junk food", "caffeine"

**Suggested reframes:**
| User types... | Suggest... |
|---------------|------------|
| "quit smoking" | "Smoke-free day" |
| "reduce phone" | "Phone under 30 mins" |
| "stop drinking" | "Alcohol-free day" |
| "less sugar" | "Sugar-free day" |

**Files Modified:**
- `lib/presentation/screens/create_habit/create_habit_screen.dart`

---

### ✅ Milestone 17: History Navigation & Past Day View
**Status**: Complete

Interactive history bar chart on home screen with period selection and past day navigation.

- [x] Create `home_history_provider.dart` with DayStats/MonthStats models
- [x] Create `date_habits_provider.dart` for date-specific habit data
- [x] Create `history_bar_chart.dart` widget with tappable bars
- [x] Create `period_selector.dart` (7d | 4w | 1y | All)
- [x] Create `date_nav_header.dart` with arrow navigation
- [x] Update home screen with history components
- [x] Create `past_day_screen.dart` for viewing/editing past days
- [x] Add pull-to-refresh to return to today
- [x] Make Atomize logo tappable to return to today
- [x] Add max-width constraint for desktop/tablet screens
- [x] Fix auth state sync trigger (habits now sync on login)

**Features:**
- **7d view**: 7 bars (1 per day), tap to navigate
- **4w view**: 28 bars (scrollable), tap to navigate
- **1y view**: 12 bars (1 per month), tap date for calendar
- **All view**: All months since first habit
- **Bar colors**: Green = 100% done, Orange = medium, Blue = low
- **Past day editing**: Last 7 days editable, beyond read-only

**Files Created:**
- `lib/presentation/providers/home_history_provider.dart`
- `lib/presentation/providers/date_habits_provider.dart`
- `lib/presentation/widgets/history_bar_chart.dart`
- `lib/presentation/widgets/period_selector.dart`
- `lib/presentation/widgets/date_nav_header.dart`
- `lib/presentation/screens/past_day/past_day_screen.dart`

**Files Modified:**
- `lib/presentation/screens/home/home_screen.dart` - Major redesign
- `lib/domain/services/sync_service.dart` - Auth state sync trigger

---

## Future Phases

### Phase 2: Enhanced Habits (V1.1) — ✅ Complete
- ~~Count-type habits~~ ✅ Done (M13)
- ~~Weekly-type habits~~ ✅ Done (M13)
- ~~Purpose prompts (after 7 days)~~ ✅ Done (M14)
- ~~Habit stacking~~ ✅ Done (M14)

### Phase 3: Smart Features (V1.2)
- Notification style system (7 styles)
- Notification learning (ML-lite)
- Smart habit templates
- ~~Smart habit reframing (M16)~~ ✅ Done
- ~~History navigation (M17)~~ ✅ Done
- History editing with credit percentages
- Weekly summary system
- ~~Break mode~~ ✅ Done (M10)
- Soft habit limits

### Phase 4: Sync & Polish (V1.3) — Partial
- ~~Supabase setup~~ ✅ Done (M12)
- ~~Anonymous auth~~ ✅ Done (M12)
- ~~Local-first sync~~ ✅ Done (M12)
- ~~Email/Apple/Google auth linking~~ ✅ Done (M15)
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
| Cloud Sync | supabase_flutter 2.8.0 |
| Notifications | flutter_local_notifications 19.5.0 |
| Fonts | google_fonts 6.3.2 |
| Code Generation | build_runner, riverpod_generator, drift_dev |

---

## Changelog

### 2025-11-26
- **Milestone 17 Complete**: History Navigation & Past Day View - Interactive bar chart on home screen with 7d/4w/1y/All period selector, past day viewing and editing, pull-to-refresh, logo tap to return to today
- **Auth Sync Fix**: Habits now automatically sync when user logs in (auth state change triggers sync)
- **Responsive Layout**: Added max-width constraints for better desktop/tablet display

### 2025-11-25
- **Milestone 15 Complete**: Account & Authentication - Email/Apple/Google sign-in options, account screen with sign-up/sign-in toggle, password reset, Google OAuth configured
- **Milestone 14 Complete (Phase 2 Done)**: Purpose Prompts & Habit Stacking - Banner prompts after 7 days for deep purpose, 3-step wizard for feelings/identity/outcomes, habit stacking selector in create/edit screens, linked habit display in details
- **Milestone 13 Complete**: Weekly Habits - Added weekly habit type with flexible weekly targets (e.g., "exercise 3x per week"), weekly progress tracking, calendar-based decay
- **Milestone 12 Complete**: Supabase Cloud Sync - Local-first sync with Supabase, anonymous auth, offline queue, connectivity monitoring
- **Count-type Habits**: Added habit type selector (binary/count/weekly), count target field, progress ring UI, increment button
- **Milestone 11 Complete**: Grace Window & Day Boundary - Multi-day decay handling, automatic decay on app start, 4am grace window for completing habits
- **Milestone 10 Complete**: Settings & Onboarding - Full settings screen with theme, notifications, quiet hours, break mode, and about. Onboarding flow with 3 screens (welcome, create habit, tutorial). Reactive theme mode.
- **Milestone 9 Complete**: Progress Bar Chart - Last 30 days completion history with flame-colored bars and stats chip
- **Milestone 8 Complete**: Basic Notifications - Pre/post reminders with quiet hours and break mode support
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

# Atomize — Design Document v1.2

> **Tagline:** Small habits. Big change.

---

## 1. Overview

### 1.1 What is Atomize?

Atomize is a cross-platform habit tracking app built on the principles from *Atomic Habits* by James Clear. It focuses on sustainable behaviour change through identity-based habits, intrinsic motivation, and gentle accountability.

### 1.2 Core Philosophy

- **Anti-addictive design:** No streaks, no anxiety-inducing mechanics, no bright dopamine-triggering animations
- **Supportive friend personality:** Encouraging but never pushy or guilt-inducing
- **Forgiveness over punishment:** Missing a day doesn't reset progress; mature habits are resilient
- **Intrinsic motivation:** Focus on *why* you want the habit, not external rewards
- **Privacy-first:** Fully offline-capable, optional sync, transparent data practices, no data selling
- **Solo experience:** No social features, no comparisons — only you vs. yesterday's you

### 1.3 Target Platforms

- iOS (iPhone, iPad)
- Android (phones, tablets)
- Web (responsive)

### 1.4 Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter |
| Local Database | SQLite (via Drift/sqflite) |
| Cloud Sync | Supabase (optional) |
| Auth | Supabase Auth (email, Apple, Google, anonymous) |
| State Management | Riverpod or Bloc |
| Notifications | firebase_messaging + flutter_local_notifications |
| Calendar Integration | device_calendar package |
| Email Service | Supabase Edge Functions + Resend |

---

## 2. Core Features

### 2.1 Habit Creation

Each habit captures the Atomic Habits "implementation intention" formula:

**Required fields:**
- **What:** The habit action (e.g., "Do yoga")
- **When:** Time of day (e.g., 7:00 AM)
- **Frequency:** Daily OR X times per week/month

**Optional fields:**
- **Where:** Location context (e.g., "Living room")
- **After:** Habit stacking link (e.g., "After morning coffee")
- **Why (quick):** Single sentence purpose (shown during onboarding)
- **Why (detailed):** Added later via prompts
  - Feelings: "How will this habit make you feel?"
  - Identity: "Who do you want to become?"
  - Outcomes: "What will you achieve?"

**Habit types:**
| Type | Example | Scoring |
|------|---------|---------|
| Binary | "Do yoga" | Done/not done |
| Count | "Drink 5 glasses of water" | Partial credit based on completion % |
| Weekly | "Gym 3x per week" | Flexible which days, scored at week end |

### 2.2 Habit Completion

**Binary habits:**
- Tap flame to mark complete
- Full score gain

**Count habits (e.g., 5 glasses of water):**
- Shows progress: "3/5 glasses"
- Tap to increment
- Scoring based on percentage:

```
100% of target: Full gain
60-99% of target: 50% gain
20-59% of target: No change
1-19% of target: No change
0% of target: Full decay
```

**Weekly habits (e.g., gym 3x/week):**
- Flexible completion any day
- Score calculated at week boundary
- Gain rate = 70% of equivalent daily habit (slower but achievable)

### 2.3 Habit Score System

**The Flame Score (0-100)**

The score represents habit strength/automaticity. Higher scores mean the habit is more ingrained.

**Visual representation:**
- 0-30: Blue flame (cold, new habit)
- 30-50: Blue-orange gradient (warming up)
- 50-80: Orange flame (building momentum)
- 80-95: Orange-red gradient (strong habit)
- 95-100: Red flame (mastered)
- 100: Red with subtle golden/white core (fully automatic)

**Score formula:**

```dart
// ========== GAIN CALCULATION ==========

// Base gain (reaches ~100 at day 30 for daily habits)
double calculateGain(double currentScore, HabitType type, int dailyTarget) {
  double baseGain = 10 * pow(1 - currentScore / 100, 0.7);
  
  // Multi-completion habits mature faster
  if (type == HabitType.count && dailyTarget > 1) {
    double maturityMultiplier = 1 + (dailyTarget - 1) * 0.3;
    // Target 5: multiplier = 2.2 → reaches 100 in ~12-14 days
    // Target 3: multiplier = 1.6 → reaches 100 in ~18-20 days
    baseGain *= maturityMultiplier;
  }
  
  // Weekly habits gain slower per completion
  if (type == HabitType.weekly) {
    baseGain *= 0.7;
  }
  
  return baseGain;
}

// ========== DECAY CALCULATION ==========

// Maturity = total days where score was > 50 (lifetime counter)
// This creates "spaced repetition" effect — old habits are resilient

double calculateDecay(double currentScore, int habitMaturity) {
  double baseDecay = 3 + (currentScore * 0.05);
  double maturityFactor = 1 / (1 + habitMaturity * 0.03);
  
  return baseDecay * maturityFactor;
}

// ========== EXAMPLES ==========

// New habit at score 80, maturity 5:
//   decay = (3 + 4) * (1 / 1.15) = 6.1 pts/day

// Mature habit at score 80, maturity 60:
//   decay = (3 + 4) * (1 / 2.8) = 2.5 pts/day

// ========== COUNT HABIT PARTIAL SCORING ==========

double calculateCountHabitChange(int completed, int target, double fullGain, double fullDecay) {
  double percentage = completed / target;
  
  if (percentage >= 1.0) return fullGain;           // Met target
  if (percentage >= 0.6) return fullGain * 0.5;     // Decent effort
  if (percentage >= 0.2) return 0;                   // Maintained
  return -fullDecay * 0.5;                           // Barely tried
}

// ========== WEEKLY HABIT SCORING ==========

// Calculated at week boundary (Sunday night / Monday 4am)
double calculateWeeklyHabitChange(int completedThisWeek, int weeklyTarget, double baseGain, double baseDecay) {
  double percentage = completedThisWeek / weeklyTarget;
  
  if (percentage >= 1.0) return baseGain * weeklyTarget * 0.7;  // Met target
  if (percentage >= 0.66) return baseGain * completedThisWeek * 0.5;  // Close
  if (percentage >= 0.33) return 0;  // Some effort, maintain
  return -baseDecay * (weeklyTarget - completedThisWeek) * 0.5;  // Missed most
}
```

**Score progression examples:**

*Perfect daily habit:*
| Day | Score | Notes |
|-----|-------|-------|
| 1 | 10 | Big initial jump |
| 7 | 55 | First week |
| 14 | 75 | Two weeks |
| 21 | 88 | Three weeks |
| 30 | 96 | One month |
| 45 | 100 | Mastered |

*5x daily count habit (e.g., water):*
| Day | Score | Notes |
|-----|-------|-------|
| 1 | 22 | Fast start |
| 5 | 65 | Almost one week |
| 10 | 88 | Strong |
| 14 | 98 | Nearly mastered |

*Inconsistent user (~4x/week):*
| Week | Score | Notes |
|------|-------|-------|
| 1 | 38 | Plateau begins |
| 4 | 58 | Stuck in orange |
| 8 | 62 | Honest feedback |

### 2.4 Hitting 100

When a user first reaches score 100:
- One-time subtle toast: *"You've mastered this habit. It's part of who you are now."*
- Flame gains subtle golden/white core (permanent while at 100)
- No confetti, no fireworks, no share prompts
- The identity shift is the reward

### 2.5 Progress Tracking

**Heatmap/Bar Chart View:**
- Default: Past 30 days as bar chart (one habit at a time)
- Zoom out: 30 bars representing weeks/months
- Similar to Garmin Connect's activity view
- Bar height represents score on that day
- Colour matches flame colour at that score

**Simple Stats (Habit Detail Screen):**
- Current score (0-100%)
- Completion rate (% of days completed in selected period)
- Time period selector: 1M | 3M | 1Y | All
- Created date

Note: Maturity (days with score > 50) is tracked internally for decay calculations but not displayed to users.

---

## 2.6 Weekly Summary System

The weekly summary is the primary reflection mechanism — one focused moment instead of scattered prompts.

### 2.6.1 Summary Timing

- **Default:** Sunday 6pm
- **Configurable:** User can change to Monday (for "week start" preference)
- **Time configurable:** User can adjust notification time
- **Notification:** "Your weekly summary is ready 📊"

### 2.6.2 Summary Flow

**Screen 1: Week Overview**

```
┌─────────────────────────────────────────┐
│                                         │
│         Week of Nov 17-23               │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 🔥 Yoga          72 → 81  ↑9   │    │
│  │ ████████████████░░░░           │    │
│  │ ✓✓✓✗✓✓✓  (6/7 days)           │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 🔥 Meditate      45 → 52  ↑7   │    │
│  │ ██████████░░░░░░░░░░           │    │
│  │ ✓✗✓✓✗✓✗  (4/7 days)           │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 💧 Water (5x)    68 → 71  ↑3   │    │
│  │ █████████████░░░░░░░           │    │
│  │ 5 5 3 5 4 5 5  (avg 4.6/day)  │    │
│  └─────────────────────────────────┘    │
│                                         │
│         Total completions: 15           │
│         Average score: 68 (+6)          │
│                                         │
│            [Continue →]                 │
│                                         │
└─────────────────────────────────────────┘
```

**Screen 2: Reflection Questions**

```
┌─────────────────────────────────────────┐
│                                         │
│         How was this week?              │
│                                         │
│  What went well?                        │
│  ┌─────────────────────────────────┐    │
│  │ Morning yoga before work felt   │    │
│  │ great...                        │    │
│  └─────────────────────────────────┘    │
│                                         │
│  What got in the way?                   │
│  ┌─────────────────────────────────┐    │
│  │ Wednesday was stressful, skipped│    │
│  │ meditation...                   │    │
│  └─────────────────────────────────┘    │
│                                         │
│  What do you want to focus on           │
│  next week?                             │
│  ┌─────────────────────────────────┐    │
│  │ Try meditation right after yoga │    │
│  │ instead of evening...           │    │
│  └─────────────────────────────────┘    │
│                                         │
│            [Continue →]                 │
│                                         │
│         (all fields optional)           │
│                                         │
└─────────────────────────────────────────┘
```

**Screen 3: Notification Feedback (Optional)**

```
┌─────────────────────────────────────────┐
│                                         │
│      Were reminders helpful?            │
│                                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐    │
│  │ Too few │ │Just right│ │Too many │    │
│  └─────────┘ └─────────┘ └─────────┘    │
│                                         │
│  How did the reminder tone feel?        │
│                                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐    │
│  │Too soft │ │Just right│ │Too pushy│    │
│  └─────────┘ └─────────┘ └─────────┘    │
│                                         │
│                                         │
│            [Continue →]                 │
│                                         │
│              Skip →                     │
│                                         │
└─────────────────────────────────────────┘
```

This feeds directly into notification ML:
- "Too pushy" → weight toward Gentle/Minimal styles
- "Too soft" → weight toward Direct/Purpose styles
- "Too many" → reduce follow-up notifications
- "Too few" → enable evening catch-up

**Screen 4: App Feedback (Occasional)**

Only shows every 4-6 weeks, or after user hits milestones:

```
┌─────────────────────────────────────────┐
│                                         │
│   Quick feedback to improve Atomize?    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ Would be nice if...             │    │
│  │                                 │    │
│  └─────────────────────────────────┘    │
│                                         │
│        [Submit]    [Skip]               │
│                                         │
│   This goes directly to the developer   │
│                                         │
└─────────────────────────────────────────┘
```

**Screen 5: Done + Donate**

```
┌─────────────────────────────────────────┐
│                                         │
│              See you next week.         │
│                                         │
│         Keep building yourself,         │
│            one day at a time.           │
│                                         │
│               [Done]                    │
│                                         │
│  ─────────────────────────────────────  │
│                                         │
│           Help support Atomize          │
│                                         │
│     No ads. No premium. Just habits.    │
│     Support development with a small    │
│     donation.                           │
│                                         │
│          [☕ Buy me a coffee]           │
│                                         │
│           Developed by Tyr              │
│                                         │
└─────────────────────────────────────────┘
```

### 2.6.3 Summary Availability Logic

```dart
enum SummaryState {
  available,      // Sunday/Monday (whenever scheduled)
  gentle,         // Monday-Tuesday — available but not prompted
  archived,       // Wednesday onwards — only in history
}

SummaryState getSummaryState(WeeklySummary summary) {
  final daysSinceWeekEnd = DateTime.now().difference(summary.weekEnd).inDays;
  
  if (daysSinceWeekEnd <= 1) return SummaryState.available;
  if (daysSinceWeekEnd <= 3) return SummaryState.gentle;
  return SummaryState.archived;
}
```

| State | Home screen | Notification | How to access |
|-------|-------------|--------------|---------------|
| Available | Banner: "Weekly summary ready" | Yes (Sunday/Monday) | Tap banner |
| Gentle | Small dot on Reflect tab | No | Navigate to Reflect |
| Archived | Nothing | No | Reflect → Past summaries |

### 2.6.4 Donate Frequency Logic

```dart
bool shouldShowDonate(WeeklySummary summary, UserStats stats) {
  // Don't spam — at most every 3 weeks
  if (stats.weeksSinceLastDonatePrompt < 3) return false;
  
  // Show on good weeks (score improved)
  if (summary.averageScoreChange >= 5) return true;
  
  // Or on milestone weeks
  if (stats.totalWeeksCompleted == 4) return true;   // 1 month
  if (stats.totalWeeksCompleted == 12) return true;  // 3 months
  if (stats.totalWeeksCompleted % 12 == 0) return true;  // Yearly
  
  // Otherwise show roughly every 4 weeks
  return stats.weeksSinceLastDonatePrompt >= 4;
}
```

### 2.6.5 Past Summaries View

Accessible via Reflect → Past summaries:

```
┌─────────────────────────────────────────┐
│                                         │
│            Past Summaries               │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ Nov 17-23                       │    │
│  │ Avg score: 68 (+6) • 15 done    │    │
│  │ Focus: "Try meditation after..."│    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ Nov 10-16                       │    │
│  │ Avg score: 62 (+3) • 12 done    │    │
│  │ Focus: "Be more consistent..."  │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ Nov 3-9                         │    │
│  │ Avg score: 59 (-2) • 9 done     │    │
│  │ Focus: "Get back on track..."   │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

Tapping a past summary shows:
- Full stats from that week
- User's reflection answers (what went well, obstacles, focus)
- Read-only, cannot edit

### 2.6.6 Email Summary (Optional)

If enabled in Settings, user receives a brief email on summary day:

```
Subject: Your weekly summary is ready

Hey [name/there],

Your Atomize weekly summary is ready.

[Open summary →]

Small habits. Big change.
```

- Clicking opens app directly to the full weekly summary flow
- Keeps email minimal — all the detail is in-app
- Name captured when user enables email summaries in Settings
- Falls back to "Hey there" if no name provided

---

## 2.7 History Editing

**Edit window with graduated credit:**
| Timeframe | Credit | Rationale |
|-----------|--------|-----------|
| Same day | 100% | Mistakes happen |
| Yesterday | 75% | Reasonable forget |
| 2-3 days ago | 50% | Life happens |
| 4+ days ago | Locked | Prevents gaming |

## 2.8 Habit Management

**Archive vs Delete:**
- **Archive:** Keeps history, maturity preserved, can resume later
- **Delete:** Permanently removes all data

**No pause feature:** If on holiday, score naturally decays. This reflects reality — habits do weaken without practice.

**Soft habit limit:**
```dart
if (activeHabits >= 4 && averageScore < 70) {
  showSoftWarning(
    "You have $activeHabits habits averaging ${averageScore.round()}%. "
    "Research suggests mastering fewer habits first increases success. "
    "Add anyway?"
  );
}

if (activeHabits >= 6) {
  showSoftWarning(
    "You have $activeHabits active habits. "
    "Consider archiving one to focus your energy."
  );
}
```

### 2.9 Breaking Bad Habits

Atomize handles breaking bad habits **without any separate feature or special code**. Users simply frame their habit positively:

| Instead of... | Frame as... |
|---------------|-------------|
| "Quit smoking" | "Smoke-free day" |
| "Reduce phone use" | "Phone under 30 mins" |
| "Max 3 drinks per week" | "Alcohol-free day 4x per week" |

**Why this works:**
- Every completion is a win — tapping the flame means success
- Weekly summary reads naturally: "Smoke-free day: 72 → 81 — 6/7 days"
- Score/maturity handles psychology perfectly — a slip drops score a few points, not to zero
- Matches reality: someone 5 months into quitting who has one cigarette hasn't lost everything

**Smart reframing suggestion:**
When users type trigger words like "stop", "quit", "reduce", "less", or items like "smoking", "alcohol", "phone", the app gently suggests reframing:

> 💡 Tip: Try framing it as what you WILL do: "Smoke-free day" — this way every completion is a win!

**No special code needed:**
- Notification styles (Minimal, Purpose-driven) work for both habit types
- Purpose prompts use habit name directly ("How does Smoke-free day make you feel?")
- No database changes, no new screens, no sync complexity

---

## 3. Notification System

### 3.1 Notification Timing

**Per habit:**
1. **Pre-reminder:** 30 minutes before scheduled time (default, configurable)
2. **Post-reminder:** 30 minutes after scheduled time if not completed
3. **Evening catch-up:** Optional, off by default, respects quiet hours

**Global quiet hours:**
- Default: 10pm - 7am
- User configurable
- Habits *scheduled* within quiet hours still notify
- Follow-up nudges respect quiet hours

### 3.2 Notification Styles

The app learns which style resonates with each user.

| Style | Example | Personality |
|-------|---------|-------------|
| Gentle | "No pressure, but yoga might feel nice today" | Soft, no guilt |
| Direct | "Yoga time. 10 minutes." | Efficient, minimal |
| Purpose | "Remember wanting to touch your toes? Yoga helps." | Why-focused |
| Minimal | "Yoga 🧘" | Just a nudge |
| Playful | "Your yoga mat misses you" | Warm, friendly |
| Recovery | "Your yoga habit needs some love. Ready to rebuild?" | Post-decay support |
| Urgent | "Habit strength drops tomorrow. 5 minutes today?" | Before critical decay |

### 3.3 ML-Based Notification Learning

**Feedback signals:**
- **Positive:** Habit completed within 30 minutes of notification
- **Neutral:** Habit completed later that day (notification style may not have helped)
- **Negative:** Notification dismissed, habit not completed that day

**Learning approach:**
- Track completion correlation per notification style per user per habit
- Start with even distribution, converge on effective styles
- Re-test occasionally to avoid local maxima
- Per-habit learning (what works for yoga may not work for meditation)

**Purpose statement rotation:**
- Notifications randomly use different "why" statements
- Prevents habituation to same message
- Tracks which purpose statements correlate with completion

### 3.4 Notification Content

**Structure:**
```
[Style-appropriate opener]
[Optional: purpose statement from user's "why"]
[Optional: minimal effort framing — "just 2 minutes"]
```

**Examples by habit state:**

*Low score (building):*
- "Starting yoga today? Even 2 minutes counts."
- "Small start: just unroll your mat. See what happens."

*Medium score (momentum):*
- "Yoga's becoming part of your routine. Keep it going?"
- "Remember why you started: [user's purpose statement]"

*High score (maintaining):*
- "Yoga time 🧘"
- "Your body knows the drill."

*Declining (recovery):*
- "Your yoga habit could use some attention. No judgment — ready when you are."
- "It's been a few days. Want to reconnect with yoga?"

---

## 4. Purpose & Motivation System

### 4.1 Initial Capture (Onboarding)

During first habit creation, single optional field:
> "Why does this matter to you?" (one sentence)

Low friction, high insight.

### 4.2 Deep Purpose Prompts (Day 7+)

After 7 days of a habit, prompt user to add depth:

**Prompt 1: Feelings**
> "How does yoga make you feel?"
> Examples: energized, calm, accomplished, flexible

**Prompt 2: Identity**
> "Who are you becoming?"
> Examples: "someone who prioritises health", "a person who shows up for themselves"

**Prompt 3: Outcomes**
> "What will you achieve?"
> Examples: "touch my toes", "reduce back pain", "feel stronger"

### 4.3 Purpose Evolution

Periodically (monthly?), prompt reflection:
> "Your original goal was '[outcome]'. Is that still what drives you, or has your 'why' evolved?"

Allow users to update purposes as they grow.

### 4.4 Smart Purpose Suggestions

When user types habit name, suggest relevant purposes:

| Habit keyword | Suggested feelings | Suggested identity | Suggested outcomes |
|---------------|-------------------|-------------------|-------------------|
| yoga, stretch | flexible, calm, centered | someone who cares for their body | touch toes, reduce pain |
| meditate | peaceful, focused, grounded | a mindful person | reduce anxiety, better focus |
| read | curious, relaxed, inspired | a lifelong learner | read 20 books/year |
| language | cultured, connected | a multilingual person | travel confidently |
| water | refreshed, healthy | someone who hydrates | clearer skin, more energy |
| exercise, gym | strong, energized | an active person | run 5K, build muscle |

---

## 5. User Experience

### 5.1 Design Principles

- **Apple-style aesthetic:** Clean, sleek, generous whitespace
- **Accessible:** Works for young and elderly users
- **Subtle animations:** Present but not excessive
- **Muted colour palette:** Calm teal accent, soft greys, no harsh colours
- **The flame is the hero:** Main visual element, colour tells the story

### 5.2 Colour Palette

```
Primary Background: #FAFAFA (light) / #1A1A1A (dark)
Secondary Background: #FFFFFF (light) / #242424 (dark)
Text Primary: #1A1A1A (light) / #F5F5F5 (dark)
Text Secondary: #6B6B6B (light) / #A0A0A0 (dark)
Accent: #4ECDC4 (calm teal)
Flame Blue: #3B82F6
Flame Orange: #F97316
Flame Red: #EF4444
Flame Gold (100): #FBBF24
Success: #10B981
Warning: #F59E0B
```

### 5.3 Onboarding Flow

**Total time: < 2 minutes**

```
Screen 1: Welcome (5 seconds)
┌─────────────────────────────────────────┐
│                                         │
│         🔥 Atomize                      │
│    Small habits. Big change.            │
│                                         │
│      ┌─────────────────────┐            │
│      │    Get Started      │            │
│      └─────────────────────┘            │
│                                         │
│   Already have an account?              │
│          Sign in →                      │
│                                         │
└─────────────────────────────────────────┘

- [Get Started] → straight to habit creation, no account needed
- [Sign in] → for returning users on new device

Screen 2: Create First Habit (60 seconds)
├── "What's one small habit you want to build?"
│   └── Text input with smart suggestions
├── "When?" → Time picker
├── "How often?" → Daily / X per week
├── "Why?" → Optional single line
├── [Create Habit]

Screen 3: Quick Tutorial (15 seconds)
├── Shows habit card with blue flame
├── "Tap the flame when you've done it."
├── Flame animates to slightly warmer colour
├── [Got it]

→ Home screen
```

**No carousels. No philosophy. No account creation required.**

### 5.4 Account Sync Prompt

After first habit created (or after 3 completions), prompt user:

```
┌─────────────────────────────────────────┐
│                                         │
│  Want to sync across devices?           │
│                                         │
│  Your habits will be backed up          │
│  and available on any device.           │
│                                         │
│  ┌───────────┐  ┌───────────┐           │
│  │  Sign up  │  │  Not now  │           │
│  └───────────┘  └───────────┘           │
│                                         │
│     ☐ Don't ask again                   │
│                                         │
└─────────────────────────────────────────┘
```

**Behaviour:**
- Never blocks core functionality
- Explains the *why* (sync, backup)
- "Don't ask again" respects user choice
- Always available in Settings if they change mind later

**Auth methods:**
- Email + password
- Sign in with Apple (iOS)
- Sign in with Google (Android/web)
- Anonymous account (syncs without email, can link email later)

### 5.5 Main Screens

**Home (Today View):**
- Rectangle list layout (not grid — flame deserves space, better tap targets)
- Each card shows: name, scheduled time, flame (current colour), score, completion state
- Sorted by: incomplete habits first (soonest scheduled at top), then completed habits below
- Tap flame to complete
- Tap card to expand (shows purpose, stats, edit)

**Habit Detail:**
- Large flame visualisation
- Current score
- Bar chart (last 30 days)
- Purpose statements
- Edit/archive/delete options

**All Habits:**
- Rectangle list of all habits
- Filter: Active / Archived
- Sort: By score, by name, by creation date

**Reflect (formerly Insights):**
- Weekly summary (when available)
- Past summaries list
- Total completions across all habits
- Overall habit health (average score)
- Not a complex dashboard

**Settings:**
- Account (optional Supabase sync)
  - Sign in / Sign up
  - Link anonymous account to email
  - Sign out
- Weekly summary
  - Summary day (default Sunday, can change to Monday)
  - Summary time (default 6pm)
  - Email summary (on/off)
  - Display name (for email personalisation)
- Taking a break (notification mute 1-30 days)
- Notification preferences
- Quiet hours
- Day boundary time (default 4am)
- Timezone lock (for travellers)
- Data export
- Delete all data
- Support Atomize (Buy Me a Coffee link)
- About / Privacy policy

### 5.6 Widgets

**iOS Widget (Small):**
- Today's top 3 habits by scheduled time
- Tap to quick-complete

**iOS Widget (Medium):**
- All today's habits
- Flame colour visible
- Tap to complete

**Android Widget:**
- Similar to iOS medium
- Quick-complete buttons

### 5.7 Grace Window

All habits can be marked complete until 4am the next day. This covers night owls naturally without needing explicit "log yesterday" functionality.

### 5.8 Break Mode (Notification Mute)

For holidays or breaks, users can mute all notifications:

```
┌─────────────────────────────────────────┐
│                                         │
│  Taking a break?                        │
│                                         │
│  Mute all notifications for:            │
│                                         │
│      ┌─────────────────────┐            │
│      │   ◀   7 days   ▶    │            │
│      └─────────────────────┘            │
│            (1-30 days)                  │
│                                         │
│  Your habits will still be here when    │
│  you get back. Scores may drop — that's │
│  normal.                                │
│                                         │
│  ┌───────────┐  ┌───────────┐           │
│  │   Cancel  │  │   Mute    │           │
│  └───────────┘  └───────────┘           │
│                                         │
└─────────────────────────────────────────┘
```

**Behaviour:**
- No habit notifications for X days
- Score decays as normal (honest — habits do weaken)
- After X days, notifications resume automatically
- Can end break early anytime in Settings
- Weekly summary still generated but not notified

**Access:** Settings → "Taking a break?"

### 5.9 Logo & Branding

**Atomize Wordmark:**

The app name is displayed as a styled wordmark with the following characteristics:

```
At🔥mize
```

**Design specifications:**
- **Text:** "Atomize" with only capital A
- **The "o":** Replaced with a flame icon (teardrop shape, same as habit flames)
- **Gradient:** Linear gradient from blue (#3B82F6) on the left to orange (#F97316) on the right
- **Font:** Inter Bold (weight 700)
- **Animation:** Static (no flickering for the logo flame)

**Color progression across letters:**
```
A    t    🔥    m    i    z    e
│    │    │     │    │    │    │
Blue ─────────────────────→ Orange
```

**Usage:**
| Context | Font Size | Notes |
|---------|-----------|-------|
| Home screen app bar | 24px | Centered, with "Today" section header below |
| Onboarding welcome | 48px | Large, centered, with tagline |
| Splash screen | 48px | Future implementation |

**Tagline:** "Small habits. Big change."

---

## 6. Data Architecture

### 6.1 Local-First Philosophy

```
SQLite (local) = Source of truth
        ↓ (when online + user opts in)
Supabase (cloud) = Backup + sync
```

- App works 100% offline forever
- Cloud sync is optional convenience
- If servers shut down, users keep everything

### 6.2 Data Models

```dart
// ========== HABIT ==========
class Habit {
  String id;                    // UUID
  String name;                  // "Do yoga"
  String? where;                // "Living room"
  String? afterHabit;           // ID of habit to stack after
  TimeOfDay scheduledTime;      // 07:00
  HabitType type;               // binary, count, weekly
  int? countTarget;             // For count type: 5 (glasses)
  int? weeklyTarget;            // For weekly type: 3 (times)
  
  double score;                 // 0-100
  int maturity;                 // Days with score > 50
  
  String? quickWhy;             // "To feel more flexible"
  String? feelingWhy;           // "Calm and centered"
  String? identityWhy;          // "Someone who prioritizes health"
  String? outcomeWhy;           // "Touch my toes"
  
  DateTime createdAt;
  DateTime? archivedAt;
  bool isArchived;
  
  // Settings
  int preReminderMinutes;       // Default 30
  bool postReminderEnabled;     // Default true
  bool eveningCatchupEnabled;   // Default false
}

// ========== COMPLETION ==========
class HabitCompletion {
  String id;
  String visaId;
  DateTime date;                // The day this completion is for
  DateTime completedAt;         // When user tapped complete
  int? countValue;              // For count habits: how many
  double scoreAfter;            // Score after this completion
  double scoreChange;           // +8.5 or -3.2
  CompletionSource source;      // manual, backfill
}

enum CompletionSource {
  manual,           // User tapped in real-time
  backfill          // User logged for previous day (within grace window)
}

// ========== NOTIFICATION LOG ==========
class NotificationLog {
  String id;
  String visaId;
  DateTime sentAt;
  NotificationStyle style;
  String content;
  NotificationOutcome outcome;
  int? minutesToCompletion;     // If completed, how long after
}

enum NotificationStyle {
  gentle, direct, purpose, minimal, playful, recovery, urgent
}

enum NotificationOutcome {
  completedWithin30,     // Strong positive signal
  completedLater,        // Weak positive / neutral
  dismissed,             // Neutral
  ignoredNotCompleted    // Negative signal
}

// ========== USER PREFERENCES ==========
class UserPreferences {
  TimeOfDay quietHoursStart;    // Default 22:00
  TimeOfDay quietHoursEnd;      // Default 07:00
  TimeOfDay dayBoundary;        // Default 04:00
  bool lockTimezone;            // For travellers
  String? lockedTimezone;       // "Europe/London"
  
  // Weekly summary settings
  DayOfWeek summaryDay;         // Default Sunday
  TimeOfDay summaryTime;        // Default 18:00
  bool emailSummaryEnabled;     // Default false
  String? displayName;          // For email personalisation
  
  // Break mode
  DateTime? breakModeUntil;     // Notifications muted until this date
  
  // Per-style effectiveness scores (learned)
  Map<NotificationStyle, double> styleEffectiveness;
}

// ========== WEEKLY SUMMARY ==========
class WeeklySummary {
  String id;
  DateTime weekStart;              // Monday
  DateTime weekEnd;                // Sunday
  
  // Stats
  Map<String, HabitWeekStats> habitStats;  // habitId → stats
  int totalCompletions;
  double averageScore;
  double averageScoreChange;       // vs previous week
  
  // Reflections (optional, user-entered)
  String? whatWentWell;
  String? whatGotInTheWay;
  String? nextWeekFocus;
  
  // Notification feedback (optional)
  NotificationFrequencyFeedback? frequencyFeedback;
  NotificationToneFeedback? toneFeedback;
  
  // App feedback (occasional)
  String? appFeedback;
  
  // Meta
  DateTime createdAt;
  DateTime? completedAt;           // When user finished summary
  bool emailSent;
  bool donateShown;
  bool donateTapped;
}

class HabitWeekStats {
  String habitId;
  String habitName;
  double scoreStart;
  double scoreEnd;
  double scoreChange;
  int completions;
  int targetCompletions;           // 7 for daily, 3 for 3x/week, etc.
  List<int>? countValues;          // For count habits: [5, 5, 3, 5, 4, 5, 5]
}

enum NotificationFrequencyFeedback { tooFew, justRight, tooMany }
enum NotificationToneFeedback { tooSoft, justRight, tooPushy }

// ========== SYNC ==========
class SyncMetadata {
  DateTime lastSyncedAt;
  String? visabaseUserId;        // Anonymous or email-based
  List<String> pendingChanges;  // IDs of unsynced records
}
```

### 6.3 Supabase Schema

```sql
-- Users (optional, for sync)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE,              -- NULL for anonymous
  auth_provider TEXT,             -- 'email', 'apple', 'google', 'anonymous'
  display_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User preferences
CREATE TABLE user_preferences (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  quiet_hours_start TIME DEFAULT '22:00',
  quiet_hours_end TIME DEFAULT '07:00',
  day_boundary TIME DEFAULT '04:00',
  lock_timezone BOOLEAN DEFAULT FALSE,
  locked_timezone TEXT,
  summary_day TEXT DEFAULT 'sunday',  -- 'sunday' or 'monday'
  summary_time TIME DEFAULT '18:00',
  email_summary_enabled BOOLEAN DEFAULT FALSE,
  display_name TEXT,                  -- For email personalisation
  break_mode_until TIMESTAMPTZ,       -- Notifications muted until this date
  style_effectiveness JSONB DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Habits
CREATE TABLE habits (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  name TEXT NOT NULL,
  where_context TEXT,
  after_habit_id UUID REFERENCES habits(id),
  scheduled_time TIME,
  habit_type TEXT NOT NULL,    -- 'binary', 'count', 'weekly'
  count_target INT,
  weekly_target INT,
  score DECIMAL(5,2) DEFAULT 0,
  maturity INT DEFAULT 0,
  quick_why TEXT,
  feeling_why TEXT,
  identity_why TEXT,
  outcome_why TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  archived_at TIMESTAMPTZ,
  is_archived BOOLEAN DEFAULT FALSE,
  pre_reminder_minutes INT DEFAULT 30,
  post_reminder_enabled BOOLEAN DEFAULT TRUE,
  evening_catchup_enabled BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Completions
CREATE TABLE completions (
  id UUID PRIMARY KEY,
  habit_id UUID REFERENCES habits(id) ON DELETE CASCADE,
  completion_date DATE NOT NULL,
  completed_at TIMESTAMPTZ NOT NULL,
  count_value INT,
  score_after DECIMAL(5,2),
  score_change DECIMAL(5,2),
  source TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notification logs (for ML learning)
CREATE TABLE notification_logs (
  id UUID PRIMARY KEY,
  habit_id UUID REFERENCES habits(id) ON DELETE CASCADE,
  sent_at TIMESTAMPTZ NOT NULL,
  style TEXT NOT NULL,
  content TEXT,
  outcome TEXT,
  minutes_to_completion INT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Weekly summaries
CREATE TABLE weekly_summaries (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  week_start DATE NOT NULL,
  week_end DATE NOT NULL,
  
  -- Stats (stored as JSON for flexibility)
  habit_stats JSONB NOT NULL,
  total_completions INT NOT NULL,
  average_score DECIMAL(5,2),
  average_score_change DECIMAL(5,2),
  
  -- Reflections
  what_went_well TEXT,
  what_got_in_the_way TEXT,
  next_week_focus TEXT,
  
  -- Feedback
  frequency_feedback TEXT,        -- 'too_few', 'just_right', 'too_many'
  tone_feedback TEXT,             -- 'too_soft', 'just_right', 'too_pushy'
  app_feedback TEXT,
  
  -- Meta
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  email_sent BOOLEAN DEFAULT FALSE,
  donate_shown BOOLEAN DEFAULT FALSE,
  donate_tapped BOOLEAN DEFAULT FALSE,
  
  UNIQUE(user_id, week_start)
);

-- Row Level Security
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_summaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only access their own habits"
  ON habits FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Users can only access their own completions"
  ON completions FOR ALL USING (
    habit_id IN (SELECT id FROM habits WHERE user_id = auth.uid())
  );

CREATE POLICY "Users can only access their own weekly summaries"
  ON weekly_summaries FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Users can only access their own preferences"
  ON user_preferences FOR ALL USING (user_id = auth.uid());
```

### 6.4 Data Export

Users can export all data as JSON:

```json
{
  "exported_at": "2025-01-15T10:30:00Z",
  "habits": [...],
  "completions": [...],
  "weekly_summaries": [...],
  "preferences": {...}
}
```

Available in Settings → Export Data

### 6.5 Data Deletion

Full GDPR-style deletion:
- Settings → Delete All Data
- Confirmation prompt
- Removes local SQLite database
- If synced, removes from Supabase
- Irreversible

---

## 7. Calendar Integration

### 7.1 Supported Calendars

- Apple Calendar (iOS/macOS)
- Google Calendar
- Proton Calendar (via CalDAV)
- Any CalDAV-compatible calendar

### 7.2 Integration Options

**Option A: View habits in calendar (read-only export)**
- Creates calendar events for scheduled habits
- Updates automatically when habit time changes

**Option B: Block time for habits**
- Creates "busy" blocks for habit time
- Helps protect habit time from other commitments

**Option C: Smart scheduling (future)**
- Suggests optimal habit times based on calendar availability

### 7.3 Implementation

Using `device_calendar` Flutter package:
- Request calendar permissions
- Let user choose which calendar to sync to
- Create recurring events for each habit
- Update events when habits change

---

## 8. Privacy & Transparency

### 8.1 Data Collection

**What we collect (with sync enabled):**
- Habit names and details
- Completion timestamps
- Notification interaction data (for ML learning)
- No personal identifiers beyond optional email

**What we DON'T collect:**
- Location data
- Device identifiers
- Usage analytics
- Data from other apps

### 8.2 Data Usage

All data is used solely to:
- Sync habits across user's devices
- Improve notification effectiveness for that user
- Never sold, never shared, never used for ads

### 8.3 Transparency Features

- Clear privacy policy in app
- Data export always available
- Full deletion always available
- Works offline = user always in control

---

## 9. Monetisation

### 9.1 Philosophy

- **100% free forever**
- No paid features
- No ads
- No data selling
- No premium tiers

### 9.2 Optional Donations

**Primary placement: Weekly Summary (Screen 5)**

After completing reflection, users see donate option:
> "Help support Atomize"
> 
> No ads. No premium. Just habits. Support development with a small donation.
> 
> [☕ Buy me a coffee]
> 
> Developed by Tyr

→ Opens buymeacoffee.com/tyrbujac

**Donate frequency logic:**
- Shows at most every 3 weeks
- More likely on good weeks (score improved by 5+)
- Appears on milestone weeks (1 month, 3 months, yearly)
- Never blocks functionality

**Secondary placement: Settings**

Settings screen also includes:
> "Atomize is free and always will be. If it's helped you build better habits, consider buying me a coffee."
> 
> [☕ Support Atomize]

### 9.3 Sustainability

If donations don't cover costs:
- Reduce server costs (Supabase free tier)
- App continues working offline forever
- Open source consideration (community maintenance)
- Never compromise core principles for revenue

---

## 10. Future Considerations

### 10.1 Potential V2 Features

- Apple Health / Google Fit integration (auto-complete habits like "exercise" based on health data)
- Apple Watch / WearOS companion
- Shortcuts/automation integration (Siri, Google Assistant)
- Advanced insights (optional, for users who want data)
- Habit categories/grouping

### 10.2 Will NOT Add

- Social features / sharing
- Leaderboards
- Achievements / badges (beyond hitting 100)
- Streak counters
- Push notification ads
- Premium features

---

## 11. Development Phases

### Phase 1: Core MVP (V1.0) ✅

- [x] Habit CRUD (binary type only)
- [x] Score system with flame visualisation
- [x] Basic completion tracking
- [x] Heatmap/bar chart view
- [x] Local SQLite storage
- [x] Basic notifications (fixed time)
- [x] Light/dark mode

### Phase 2: Enhanced Habits (V1.1) ✅

- [x] Count-type habits
- [x] Weekly-type habits
- [x] Purpose prompts (feelings/identity/outcomes after 7 days)
- [x] Habit stacking (after X, do Y)

### Phase 3: Smart Features (V1.2)

- [ ] Notification style variations
- [ ] ML-based notification learning
- [ ] Smart habit templates
- [ ] History editing with graduated credit
- [ ] Weekly summary system
- [ ] Past summaries view
- [x] Break mode (notification mute)

### Phase 4: Sync & Polish (V1.3) — Partial

- [x] Supabase integration (optional sync)
- [x] Auth (anonymous auto-sign-in)
- [ ] Auth (email, Apple, Google linking)
- [ ] Account sync prompt flow
- [ ] Email weekly summaries
- [ ] iOS/Android widgets
- [ ] Calendar integration
- [ ] Data export
- [ ] Full GDPR compliance

### Phase 5: Platform Expansion (V1.4)

- [ ] Web version
- [ ] iPad optimisation
- [ ] Tablet Android optimisation

---

## 12. Success Metrics

### 12.1 User Health (Not Engagement)

Traditional apps optimise for:
- Daily active users
- Session length
- Notification tap rates

Atomize optimises for:
- **Habit completion rates** (are users actually doing habits?)
- **Score progression** (are habits getting stronger?)
- **Retention of users with high scores** (do successful users stay?)
- **Recovery rate** (do users bounce back after decay?)

### 12.2 Qualitative Signals

- App Store reviews mentioning "not stressful"
- Users reporting actual behaviour change
- Low notification opt-out rates
- Donation rate (users who love it enough to support)

---

## Appendix A: Atomic Habits Principles Applied

| Principle | Implementation |
|-----------|----------------|
| Make it obvious | Clear "when" and "where" during creation |
| Make it attractive | Purpose prompts tie habit to identity/feelings |
| Make it easy | "Just 2 minutes" messaging, minimal friction |
| Make it satisfying | Flame colour progression, subtle 100 celebration |
| Habit stacking | "After [X], I will [Y]" field |
| Implementation intentions | What + when + where capture |
| Identity-based habits | "Who do you want to become?" prompt |
| 1% better | Score system rewards small consistent gains |
| Never miss twice | Decay is gentle, recovery is achievable |

---

## Appendix B: Notification Copy Bank

### By Style

**Gentle:**
- "No pressure, but [habit] might feel nice today."
- "Whenever you're ready for [habit]. No rush."
- "Your [habit] is here when you want it."

**Direct:**
- "[Habit] time."
- "[Habit]. 10 minutes."
- "Ready for [habit]?"

**Purpose-driven:**
- "Remember wanting to [outcome]? [Habit] helps."
- "You said [habit] makes you feel [feeling]."
- "Becoming [identity] — [habit] is part of that."

**Minimal:**
- "[Habit] 🔥"
- "[Habit] ✓"
- "Time for [habit]"

**Playful:**
- "Your [habit] misses you."
- "[Habit] is calling your name."
- "Guess what time it is? [Habit] time."

**Recovery:**
- "Your [habit] could use some love."
- "Ready to reconnect with [habit]?"
- "[Habit] habit needs attention. You've got this."

**Urgent:**
- "Habit strength drops tomorrow. 5 minutes today?"
- "Quick [habit] session to maintain momentum?"

### By Habit State

**New (score < 30):**
- "Building your [habit] habit. Every time counts."
- "Starting [habit]? Even 2 minutes matters."

**Growing (30-60):**
- "[Habit] is becoming routine. Keep it going."
- "You're building something good with [habit]."

**Strong (60-85):**
- "[Habit] time — your body knows the drill."
- "[Habit] is part of your day now."

**Mastered (85+):**
- "[Habit] 🔥"
- Quick tap — [habit] is automatic now."

---

*Document version: 1.2.1*
*Last updated: November 25, 2025*
*Author: Tyr + Claude*
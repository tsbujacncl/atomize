# Atomize - Design Document

## Overview

Atomize is a habit-tracking application that uses principles of atomic decay and half-lives as a metaphor for habit formation, maintenance, and degradation. The app helps users build and maintain habits by visualizing their consistency through radioactive decay mechanics.

## Core Concept

### Half-Life Mechanism

The application uses the concept of **half-lives** to track habit strength. Just as radioactive materials decay over time, habits in Atomize decay when not practiced, and grow stronger when consistently performed.

![Half-Lives Decay Chart](../assets/images/half-lives.png)

As shown in the diagram above, habit strength follows an exponential decay curve when not maintained:
- **N�** represents the initial habit strength (100%)
- After **1 half-life (T�/�)**: Habit strength drops to 50%
- After **2 half-lives**: Habit strength drops to 25%
- After **3 half-lives**: Habit strength drops to 12.5%
- After **4 half-lives**: Habit strength drops to 6.25%
- And so on...

The pie charts illustrate the remaining active portion (purple) versus the decayed portion (orange/yellow) of the habit at each half-life interval.

## Key Features

### 1. Habit Creation
- Users can create custom habits with personalized half-life periods
- Define the frequency of habit performance (daily, weekly, custom intervals)
- Set custom decay rates based on habit difficulty and personal goals

### 2. Habit Strength Visualization
- Real-time visual representation of habit strength using decay curves
- Color-coded indicators showing habit health
- Pie chart views showing active vs. decayed portions
- Timeline views showing habit consistency over time

### 3. Half-Life Configuration
- Customizable half-life periods per habit
- Shorter half-lives for habits requiring daily attention
- Longer half-lives for habits with more flexibility
- Dynamic adjustment based on user performance

### 4. Smart Notifications & Motivation
- Intelligent, context-aware notifications that adapt to user behavior
- Dynamic messaging that's encouraging rather than demanding
- Purpose-driven reminders tied to personal motivations
- Multi-device sync for consistent notification experience
- Streak tracking to maintain habit strength
- Recovery mechanisms to rebuild decayed habits

### 5. Progress Tracking
- Historical data showing habit strength over time
- Statistics on consistency and recovery patterns
- Achievement system based on maintaining high habit strength

## Smart Notification System

### Overview
Atomize uses intelligent, adaptive notifications that encourage users rather than pressure them. The notification system learns from user behavior and adapts its messaging to maximize motivation and habit completion.

### Dynamic Notification Messaging

#### Context-Aware Tone
Notifications adapt based on multiple factors:

**Habit Strength:**
- **Strong (>75%)**: Celebratory and reinforcing
  - "You're crushing it! Keep that yoga streak alive"
- **Moderate (40-75%)**: Encouraging and supportive
  - "Hey, want to feel more flexible? Just 2 mins of yoga could help"
- **Weak (<40%)**: Gentle and compassionate
  - "No pressure, but your mind and body might appreciate some yoga today"

**Time of Day:**
- **Morning**: Energizing and fresh start focused
  - "Start your day with 2 minutes of movement?"
- **Afternoon**: Re-energizing and break-focused
  - "Time for a quick yoga break to reset?"
- **Evening**: Relaxing and completion-focused
  - "Wind down with some gentle stretching?"

**Streak Status:**
- **On streak**: Motivating continuity
  - "Day 7! Your flexibility journey is looking good"
- **Broken streak**: Compassionate recovery
  - "Every expert was once a beginner. Ready to restart?"

**Decay Urgency:**
- **Early decay (>50%)**: Casual reminder
  - "Haven't seen you stretch in a bit. Everything okay?"
- **Critical decay (<25%)**: Supportive urgency
  - "Your habit is fading. Want to bring it back to life?"

### Purpose-Driven Notifications

Each habit includes user-defined purpose statements that appear in notifications to reinforce intrinsic motivation.

#### Guided Purpose Creation
During habit setup, users answer prompts like:
- "How will this habit make you feel?" → *"More flexible and energized"*
- "Who do you want to become?" → *"Someone who prioritizes wellness"*
- "What will you achieve?" → *"Better posture and less back pain"*

#### Purpose Integration Examples
Instead of generic reminders, notifications reference personal motivations:

- **Without purpose**: "Time to do yoga"
- **With purpose**: "Ready to feel more flexible? Just 2 mins of yoga"

- **Without purpose**: "Don't forget your meditation"
- **With purpose**: "Want that mental clarity you've been building? Quick meditation session?"

- **Without purpose**: "You should exercise"
- **With purpose**: "Become the healthy person you're working toward. Quick workout?"

### Notification Examples

**Gentle Encouragement (Low Strength):**
> "No judgment here. Want to give yoga just 2 minutes? You might feel better afterward."

**Purpose + Gentle (Moderate Strength):**
> "Remember that flexibility you're working toward? A quick stretch session could help."

**Celebratory (High Strength):**
> "10-day streak! You're building real strength here. Keep it going?"

**Recovery (Post-decay):**
> "Your meditation habit needs some love. Ready to rebuild that mental clarity?"

**Time-sensitive (Before critical decay):**
> "Your habit strength drops to 30% tomorrow. Want to prevent that? Just 5 minutes today."

## Multi-Device Notification Intelligence

### Cross-Device Sync
Users often interact with habits across multiple devices (phone, tablet, watch). Atomize syncs notification preferences and learning across all devices for a consistent experience.

### What Gets Synced
**Synced data (encrypted):**
- Notification effectiveness patterns (which styles get responses)
- Optimal notification timing per habit
- Preferred tone/style preferences
- Which purpose phrasings resonate best

**NOT synced (stays private):**
- Actual habit names or descriptions
- Specific purpose statements (content)
- Personal details or identifiable information

### Local Intelligence
The app learns which notification approaches work best for each user:

**Tracking (on-device and optionally synced):**
- Notification sent → Habit completed within timeframe (yes/no)
- Time from notification to completion
- Which message styles correlate with completion

**Adaptation:**
```
If "gentle + purpose + 2-min suggestion" → 85% completion
and "direct + time-based" → 40% completion
→ Prioritize gentle, purpose-focused notifications
```

**Privacy-First Learning:**
- All learning happens through anonymous pattern matching
- No personal content is analyzed
- Users can disable adaptive learning entirely
- Data can be purged at any time

## Purpose & Motivation System

### The "Why" Behind Habits

Research shows intrinsic motivation (internal drive) is far more effective than extrinsic motivation (external pressure) for long-term behavior change. Atomize captures and reinforces users' personal "why" for each habit.

### Guided Purpose Prompts

During habit creation, users are guided through reflection questions:

**Prompt 1: Feelings**
- "How will this habit make you feel?"
- Examples: "energized", "calm", "accomplished", "healthy"

**Prompt 2: Identity**
- "Who do you want to become?"
- Examples: "someone who prioritizes health", "a morning person", "a consistent learner"

**Prompt 3: Outcomes**
- "What will you achieve?"
- Examples: "run a 5K", "reduce stress", "learn Spanish", "better sleep"

### Multiple "Why" Statements

Users can define multiple purpose statements for a single habit:
- Habit: **Yoga**
  - Feel: "More flexible and less tense"
  - Become: "Someone who takes care of their body"
  - Achieve: "Touch my toes and reduce back pain"

Notifications randomly rotate through these statements to keep them fresh and prevent habituation.

### Purpose Evolution

As users progress, they can update their "why":
- Initial: "Lose weight" (extrinsic)
- Evolved: "Feel energized and strong in my body" (intrinsic)

The app can prompt users after streak milestones: "You've kept this up for 30 days! Has your 'why' evolved?"

## Technical Architecture

### Data Model

#### Habit
```dart
class Habit {
  String id;
  String name;
  String description;
  DateTime createdAt;
  Duration halfLife;          // Time period for 50% decay
  double currentStrength;     // Current strength (0-100%)
  DateTime lastPerformed;
  int streak;
  List<HabitLog> logs;

  // Purpose/Why fields
  HabitPurpose purpose;

  // Notification preferences
  NotificationPreferences notificationPrefs;
}

class HabitPurpose {
  String? feelStatement;      // "How will this make you feel?"
  String? becomeStatement;    // "Who do you want to become?"
  String? achieveStatement;   // "What will you achieve?"
  DateTime lastUpdated;
}

class NotificationPreferences {
  bool enabled;
  List<TimeOfDay> preferredTimes;
  NotificationTone tone;      // gentle, direct, motivational, auto
  bool adaptiveLearning;      // Allow AI to optimize notifications
  Map<String, double> styleEffectiveness; // Local learning data
}

enum NotificationTone {
  gentle,
  direct,
  motivational,
  auto  // Let the system decide based on context
}
```

#### HabitLog
```dart
class HabitLog {
  String id;
  String habitId;
  DateTime timestamp;
  double strengthBefore;
  double strengthAfter;
  bool wasPerformed;
  String? notificationStyle;  // Track which notification led to this
}
```

#### UserPreferences
```dart
class UserPreferences {
  String userId;

  // Notification intelligence settings
  bool enableNotificationSync;     // Sync across devices
  bool enableAdaptiveLearning;     // Let app learn optimal notifications
  DateTime? syncOptInDate;

  // Privacy settings
  bool shareAnonymousPatterns;     // Contribute to system-wide learning
  bool localOnlyMode;              // Disable all cloud features

  // Global notification settings
  bool notificationsEnabled;
  TimeRange quietHours;
}

class TimeRange {
  TimeOfDay start;
  TimeOfDay end;
}
```

### Calculations

#### Decay Formula
The habit strength follows exponential decay:

```
N(t) = N� � (1/2)^(t/T�/�)

Where:
- N(t) = Current strength at time t
- N� = Initial strength (100% or previous value)
- t = Time elapsed since last performance
- T�/� = Half-life period
```

#### Strength Recovery
When a habit is performed, strength increases based on:
- Current strength level
- Consistency of recent performance
- Configured growth rate

```
New Strength = min(100%, Current Strength + Recovery Boost)
Recovery Boost = Base Boost � Streak Multiplier
```

## User Experience Flow

### 1. Onboarding

#### Step 1: Welcome & Core Concept
- Introduction to the half-life concept
- Interactive visualization showing decay and recovery
- "Your habits are alive - keep them strong or watch them fade"

#### Step 2: Privacy & Notification Intelligence (Critical)
**Transparent opt-in presented during account creation:**

> **Make Your Notifications Smarter**
>
> Atomize can learn which reminders keep you motivated and sync them across all your devices.
>
> **What we'll sync:**
> - Which notification styles work for you (gentle vs direct)
> - Best times to remind you
> - Notification effectiveness patterns
>
> **What stays private:**
> - Your habit names and details
> - Your personal "why" statements
> - Any identifiable information
>
> All learning happens through encrypted, anonymous patterns. You can change this anytime in Settings or disable it completely.
>
> [ ] **Enable Smart Notifications** (Recommended)
> Sync notification preferences across devices and let the app learn what motivates you
>
> [ ] **Local Only**
> Keep everything on this device without cloud sync or learning

**Key principles for this step:**
- **Transparency first**: Clear explanation before any data collection
- **User control**: Explicit opt-in, not opt-out or buried in ToS
- **Easy to understand**: No legal jargon
- **Visible choice**: Not hidden in settings, presented upfront
- **Changeable**: Clearly stated that this can be modified later

#### Step 3: Sample Habit Creation
- Tutorial showing how habits decay and recover
- Guided habit creation with purpose prompts:
  - Name your habit
  - Set half-life period
  - Answer purpose questions (feel, become, achieve)
  - See how purpose appears in notifications
- Interactive preview of different notification styles

### 2. Daily Interaction
- Dashboard showing all habits with current strength
- Quick-check interface to mark habits as completed
- Visual decay warnings for at-risk habits

### 3. Long-term Engagement
- Weekly/monthly reports on habit health
- Insights into decay patterns and optimal half-life periods
- Recommendations for habit adjustments

## Visual Design

### Color Scheme
- **Purple**: Active/healthy habit strength
- **Orange/Yellow**: Decayed portion
- **Gradient**: Transition states during decay
- **Red**: Critical decay warnings
- **Green**: Strong habits and achievements

### UI Components
- Decay curve graphs (similar to reference image)
- Pie charts for at-a-glance habit health
- Timeline views for historical tracking
- Card-based habit list with strength indicators

## Future Enhancements

### Phase 2 Features
- Social features (accountability partners)
- Habit dependencies and chains
- Custom decay curve shapes
- Integration with other tracking apps
- Gamification elements (nuclear-themed achievements)

### Phase 3 Features
- AI-powered half-life recommendations
- Predictive analytics for habit success
- Community challenges
- Export and data portability

## Technical Stack

### Frontend
- **Framework**: Flutter
- **State Management**: Riverpod/Provider
- **Local Storage**: Hive/SQLite (encrypted)
- **Charts**: fl_chart or syncfusion_flutter_charts
- **Notifications**: flutter_local_notifications + firebase_messaging
- **Encryption**: flutter_secure_storage

### Backend
- **API**: Firebase/Supabase
- **Authentication**: Firebase Auth / Supabase Auth
- **Cloud Storage**: Firestore/Supabase DB (for sync only, not habit details)
- **Analytics**: Privacy-first custom analytics (no third-party tracking)
- **Notification Intelligence**: Custom ML model for pattern learning
- **Encryption**: End-to-end encryption for synced preferences

### Infrastructure
- **Multi-device sync**: Real-time sync of notification preferences
- **Notification scheduler**: Smart scheduling based on learned patterns
- **Privacy controls**: User preference management system
- **Data export**: JSON/CSV export functionality
- **Backup**: Optional encrypted cloud backup

## Success Metrics

- User retention rates
- Average habit strength across users
- Number of habits maintained above 50% strength
- User engagement frequency
- Recovery rates from decayed habits

## Implementation Roadmap

### MVP (Minimum Viable Product)
1. Habit creation and configuration
2. Basic decay calculation and visualization
3. Manual habit check-ins
4. Simple strength indicators
5. Local data persistence

### V1.0
1. Advanced visualizations (graphs, charts)
2. Notifications and reminders
3. Streak tracking
4. Historical data views
5. Theme customization

### V2.0
1. Cloud sync
2. Social features
3. Advanced analytics
4. AI recommendations
5. Cross-platform support

## Design Principles

1. **Simplicity**: Make habit tracking effortless
2. **Visual Clarity**: Use decay visualization to drive understanding
3. **Scientific Grounding**: Base mechanics on real radioactive decay
4. **Motivation**: Gamify without overwhelming
5. **Flexibility**: Allow users to customize their experience

## Privacy & Data Principles

Atomize is built with privacy as a core value, not an afterthought. We believe users should have full control over their data and understand exactly what's collected and why.

### Core Commitments

1. **Consent First**
   - All data collection requires explicit user consent
   - Privacy choices presented during onboarding, not buried in settings
   - Clear, jargon-free explanations of what data is collected
   - Easy to opt-out at any time

2. **Minimal Data Collection**
   - Only collect what's necessary for features to work
   - Notification learning uses anonymous patterns, not personal content
   - No tracking of habit names, purposes, or personal details in analytics
   - No third-party tracking or advertising SDKs

3. **User Control**
   - Users can disable adaptive learning completely
   - Option to use app fully offline (local-only mode)
   - All synced data can be deleted on demand
   - Export all personal data at any time
   - Account deletion removes all associated data

4. **Transparency**
   - Clear documentation of what data is synced vs stored locally
   - No hidden data collection
   - Open about how notification learning works
   - Regular privacy updates communicated to users

5. **Security**
   - End-to-end encryption for synced data
   - Encrypted local storage
   - Secure authentication
   - Regular security audits

### What We Collect (With Consent)

**With Smart Notifications enabled:**
- Notification effectiveness metrics (style → completion correlation)
- Optimal notification timing preferences
- Device sync tokens for multi-device support
- Anonymous usage patterns (which features are used, not what's in them)

**Never collected:**
- Habit names or descriptions
- Personal "why" statements or purpose content
- Location data
- Contacts or personal information
- Data from other apps

### Data Storage

**Local (on-device):**
- All habit details, names, descriptions
- Purpose statements and "why" content
- Complete habit logs and history
- User preferences

**Cloud (encrypted, opt-in only):**
- Notification effectiveness patterns (anonymous)
- Sync tokens for multi-device coordination
- Account authentication data
- Backup of habit structure (if user enables cloud backup)

### User Rights

Users have the right to:
- Know exactly what data is collected
- Access all their data
- Export all their data
- Delete all their data
- Use the app without cloud features
- Opt-out of learning/analytics
- Change privacy settings at any time

---

**Document Version**: 2.0
**Last Updated**: 2025-11-23
**Status**: Draft

## Changelog

### Version 2.0 (2025-11-23)
- Added Smart Notification System with dynamic, context-aware messaging
- Added Purpose & Motivation System with guided prompts
- Added Multi-Device Notification Intelligence with privacy-first sync
- Updated Data Model to include purpose fields and notification preferences
- Enhanced Onboarding Flow with explicit privacy opt-in
- Added comprehensive Privacy & Data Principles section
- Updated Technical Stack for notification intelligence and analytics
- Expanded user experience flows

### Version 1.0 (2025-11-23)
- Initial design document
- Core half-life concept and mechanics
- Basic feature set and data models

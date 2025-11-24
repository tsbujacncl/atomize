Atomize

A Minimalist Habit Tracker

"Build habits that stick. No streaks to break."
Inspired by the principles of 'Atomic Habits' by James Clear.

Atomize is an anti-streak habit tracker designed to eliminate shame and promote long-term consistency. It focuses on building "Habit Strength" rather than maintaining brittle chains of perfect days, aligning with the philosophy that one missed day is an accident, but two is the start of a new, bad habit.

1. Project Overview

Detail

Specification

Core Philosophy

Consistency over Perfection (Anti-Streak).

Target Audience

General public (Intuitive, large text, high contrast).

Platform

Flutter (iOS & Android).

Monetization

Free / Open Source (with "Buy Me a Coffee" donation link).

2. Technical Stack

Component

Technology / Tool

Purpose

Frontend

Flutter

Cross-platform UI development.

State Management

Riverpod

Simple, robust state management.

Backend / Auth

Supabase

Cloud Database (PostgreSQL) and Authentication.

Offline Sync

PowerSync + Supabase

Enables local-first data persistence and cloud synchronization.

Calendar Sync

device_calendar

For writing habits to the user's native calendar (Apple, Google, etc.).

Animations

confetti, audioplayers

For variable reward system.

3. Core Feature: Habit Strength Score (0-100%)

The app models habit formation as an asymptotic curve, where initial effort yields high gains, but later effort is required just for maintenance.

A. Active Decay (The Anti-Streak)

Logic: Scores decay by a fixed percentage (e.g., 10%) every midnight if the habit is not completed.

Visuals (Primary Feedback): The numerical score is hidden by default, represented only by the Card's Border Color/Glow. 

🟦 Seedling (0-20%): Blue (New Habit, High Risk)

🟧 Building (21-79%): Orange (Momentum, Warm)

🔥 Atomic (80-100%): Glowing Red/Gold (Automaticity, Hot)

Interaction: Tapping the habit card expands it to reveal the numerical score and context (e.g., "Strength: 64%").

B. The "Muscle Memory" Archive Decay

When a user archives a habit, the decay rate slows down significantly to reflect long-term memory, which prevents their hard work from being instantly erased.

Formula (Logarithmic Decay):


$$DailyArchiveDecay = \frac{BaseDecay}{1 + \ln(TotalReps)}$$

Variables:

BaseDecay: The fixed daily loss amount (e.g., 5 points/day).

TotalReps: The total lifetime completion count for the habit.

Effect: A habit with 365 reps will decay much slower than a habit with 5 reps while in the archive, preserving the score for months or years.

Archiving Management: Habits are visible and can be Un-archived (restored to the Home Screen) from the Settings > Archive page.

4. App Structure & UX

Tab 1: Home (Chronological Dashboard)

This view is segmented by time to reinforce implementation intention.

Layout: Habits are grouped into time buckets (Morning, Afternoon, Evening).

Card Design:

Left: Dynamic Icon (Book, Dumbbell, etc.) showing Total Reps (Cumulative Count) inside the icon.

Center: Habit Title (Bold) and The Cue (Small, italic text - e.g., "After I pour my coffee").

Gestures & Actions:

Tap + Hold Checkbox: Completes habit (with haptics/sound).

Tap Body: Shows numerical score/Total Reps.

Swipe Left: "Skip" (Marks as skipped, pauses decay for 24 hours on that habit only).

Tab 2: Review (Weekly Stats)

Focus: Consistency visualization and gentle analysis.

Heatmap: Monthly grid showing completed days.

Summary: Weekly Consistency Score (%) and simple text insights (e.g., "You are strongest on Tuesdays").

Sharing: Generates a static, non-linked image of the heatmap (Anti-Social Share).

Tab 3: Settings

Account: Guest Mode (Default) / Sign in to Sync (Supabase).

Data: Export habits and logs to CSV.

Notifications: Custom time-based push reminders (e.g., 30 mins before due).

Archive: Manage archived habits (View, Un-archive).

5. Key Features

A. The "2-Minute Rule" Mode

Interaction: Tapping the ⏱️ timer icon opens a full-screen modal.

UI: Minimal countdown timer (02:00).

Reward: When the timer hits zero, the habit is marked Complete. This removes the resistance to starting the habit.

B. Smart Suggestions ("Make It Easy" Law)

Logic: If the active decay rate is high (e.g., habit missed 3 days in a row).

Action: A prompt offers: "This seems hard right now. Want to switch to the 2-Minute Version ('Read 1 page') to keep your score?"

C. Calendar Integration (One-Way)

Action: When a habit is created with a time, the app uses device_calendar to write a recurring event to the user's native calendar (Apple, Google, etc.).

Future Roadmap: Proton Calendar sync (requires future API support).
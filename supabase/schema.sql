-- Atomize Supabase Schema
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/bzoajmlytdyqlxiptxpx/sql

-- ============================================
-- TABLES
-- ============================================

-- Habits table (mirrors local SQLite)
CREATE TABLE IF NOT EXISTS public.habits (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type TEXT DEFAULT 'binary',
    location TEXT,
    scheduled_time TEXT NOT NULL,
    score DOUBLE PRECISION DEFAULT 0.0,
    maturity INTEGER DEFAULT 0,
    quick_why TEXT,
    feeling_why TEXT,
    identity_why TEXT,
    outcome_why TEXT,
    count_target INTEGER,
    weekly_target INTEGER,
    after_habit_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_archived BOOLEAN DEFAULT FALSE,
    last_decay_at TIMESTAMPTZ,
    timer_duration INTEGER,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Completions table
CREATE TABLE IF NOT EXISTS public.habit_completions (
    id TEXT PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    habit_id TEXT NOT NULL,
    completed_at TIMESTAMPTZ NOT NULL,
    effective_date TIMESTAMPTZ NOT NULL,
    source TEXT DEFAULT 'manual',
    score_at_completion DOUBLE PRECISION NOT NULL,
    count_achieved INTEGER,
    credit_percentage DOUBLE PRECISION DEFAULT 100.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- User preferences
CREATE TABLE IF NOT EXISTS public.user_preferences (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    theme_mode TEXT DEFAULT 'system',
    notifications_enabled BOOLEAN DEFAULT TRUE,
    quiet_hours_start TEXT DEFAULT '22:00',
    quiet_hours_end TEXT DEFAULT '07:00',
    day_boundary_hour INTEGER DEFAULT 4,
    onboarding_completed BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX IF NOT EXISTS idx_habits_user_id ON public.habits(user_id);
CREATE INDEX IF NOT EXISTS idx_habits_updated_at ON public.habits(updated_at);
CREATE INDEX IF NOT EXISTS idx_completions_user_id ON public.habit_completions(user_id);
CREATE INDEX IF NOT EXISTS idx_completions_habit_id ON public.habit_completions(habit_id);
CREATE INDEX IF NOT EXISTS idx_completions_effective_date ON public.habit_completions(effective_date);

-- ============================================
-- AUTO-UPDATE TRIGGER
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_habits_updated_at ON public.habits;
CREATE TRIGGER update_habits_updated_at BEFORE UPDATE ON public.habits
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_preferences_updated_at ON public.user_preferences;
CREATE TRIGGER update_preferences_updated_at BEFORE UPDATE ON public.user_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Users can manage own habits" ON public.habits;
DROP POLICY IF EXISTS "Users can manage own completions" ON public.habit_completions;
DROP POLICY IF EXISTS "Users can manage own preferences" ON public.user_preferences;

-- Create policies - users can only access their own data
CREATE POLICY "Users can manage own habits" ON public.habits
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own completions" ON public.habit_completions
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own preferences" ON public.user_preferences
    FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- DONE!
-- ============================================
-- Tables created with Row Level Security enabled.
-- Anonymous auth will auto-create users.

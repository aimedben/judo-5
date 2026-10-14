-- ========================================================
-- JUDO CLUB SEDDOUK - SCHEMA SUPABASE POSTGRESQL (OFFLINE-FIRST)
-- Idempotent & Gratuit (Aucune ressource payante)
-- ========================================================

-- 1. Table des catégories de judo
CREATE TABLE IF NOT EXISTS public.judo_categories (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    group_code TEXT NOT NULL,
    coach1_name TEXT,
    coach2_name TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Table des coachs & entraîneurs
CREATE TABLE IF NOT EXISTS public.coaches (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    grade TEXT NOT NULL,
    phone TEXT,
    assigned_categories TEXT[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    sessions_count INT DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Table des membres / adhérents du dojo
CREATE TABLE IF NOT EXISTS public.members (
    id BIGINT PRIMARY KEY,
    qr_code TEXT NOT NULL UNIQUE,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    birth_date TEXT,
    phone TEXT,
    group_code TEXT NOT NULL,
    belt_name TEXT NOT NULL,
    status TEXT DEFAULT 'ACTIF',
    registration_date TEXT,
    photo_url TEXT,
    notes TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour recherche rapide par QR code
CREATE INDEX IF NOT EXISTS idx_members_qr_code ON public.members (qr_code);
CREATE INDEX IF NOT EXISTS idx_members_updated_at ON public.members (updated_at);

-- 4. Table des séances planifiées (Planning hebdomadaire)
CREATE TABLE IF NOT EXISTS public.scheduled_sessions (
    id TEXT PRIMARY KEY,
    category_id TEXT NOT NULL,
    category_name TEXT NOT NULL,
    group_code TEXT NOT NULL,
    day_of_week_name TEXT NOT NULL,
    date_string TEXT NOT NULL,
    formatted_display_date TEXT,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    coach_ids TEXT[] DEFAULT '{}',
    coach_names TEXT[] DEFAULT '{}',
    is_recurring_weekly BOOLEAN DEFAULT false,
    recurrence_end_date TEXT,
    series_id TEXT,
    notes TEXT,
    status TEXT DEFAULT 'SCHEDULED',
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_scheduled_sessions_date ON public.scheduled_sessions (date_string);

-- 5. Table des séances passées et clôturées (Historique Tatami)
CREATE TABLE IF NOT EXISTS public.past_sessions (
    id TEXT PRIMARY KEY,
    category_id TEXT NOT NULL,
    category_name TEXT NOT NULL,
    group_code TEXT NOT NULL,
    date_string TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    coach1_name TEXT,
    coach1_present BOOLEAN DEFAULT true,
    coach2_name TEXT,
    coach2_present BOOLEAN DEFAULT false,
    present_count INT DEFAULT 0,
    absent_count INT DEFAULT 0,
    present_member_names TEXT[] DEFAULT '{}',
    absent_member_names TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Table des présences / pointages
CREATE TABLE IF NOT EXISTS public.attendances (
    id BIGINT PRIMARY KEY,
    member_id BIGINT NOT NULL,
    date_string TEXT NOT NULL,
    time_string TEXT NOT NULL,
    timestamp BIGINT NOT NULL,
    check_in_method TEXT DEFAULT 'QR_SCAN',
    device_id TEXT DEFAULT 'DOJO_TERMINAL_1',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_member_attendance_per_day UNIQUE (member_id, date_string)
);

CREATE INDEX IF NOT EXISTS idx_attendances_member_id ON public.attendances (member_id);
CREATE INDEX IF NOT EXISTS idx_attendances_date_string ON public.attendances (date_string);

-- 7. Journal d'audit des synchronisations
CREATE TABLE IF NOT EXISTS public.sync_audit_log (
    id TEXT PRIMARY KEY,
    device_id TEXT NOT NULL,
    entity_name TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    operation_type TEXT NOT NULL,
    resolved_by TEXT DEFAULT 'TIMESTAMP_LWW',
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    details TEXT
);

-- Activer Row Level Security (RLS)
ALTER TABLE public.judo_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coaches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scheduled_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.past_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_audit_log ENABLE ROW LEVEL SECURITY;

-- Politiques RLS avec clé publique anon pour le club
CREATE POLICY IF NOT EXISTS "Allow anon read categories" ON public.judo_categories FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "Allow anon upsert categories" ON public.judo_categories FOR ALL USING (true);

CREATE POLICY IF NOT EXISTS "Allow anon read coaches" ON public.coaches FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "Allow anon upsert coaches" ON public.coaches FOR ALL USING (true);

CREATE POLICY IF NOT EXISTS "Allow anon read members" ON public.members FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "Allow anon upsert members" ON public.members FOR ALL USING (true);

CREATE POLICY IF NOT EXISTS "Allow anon read schedule" ON public.scheduled_sessions FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "Allow anon upsert schedule" ON public.scheduled_sessions FOR ALL USING (true);

CREATE POLICY IF NOT EXISTS "Allow anon read past_sessions" ON public.past_sessions FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "Allow anon upsert past_sessions" ON public.past_sessions FOR ALL USING (true);

CREATE POLICY IF NOT EXISTS "Allow anon read attendances" ON public.attendances FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "Allow anon upsert attendances" ON public.attendances FOR ALL USING (true);

CREATE POLICY IF NOT EXISTS "Allow anon read audit" ON public.sync_audit_log FOR SELECT USING (true);
CREATE POLICY IF NOT EXISTS "Allow anon insert audit" ON public.sync_audit_log FOR INSERT WITH CHECK (true);

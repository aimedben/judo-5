-- ====================================================================
-- JUDO CLUB SEDDOUK — Schéma Supabase PostgreSQL (Offre Gratuite)
-- ====================================================================

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

-- 2. Table des coachs & ceintures
CREATE TABLE IF NOT EXISTS public.coaches (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    grade TEXT NOT NULL,
    phone TEXT,
    assigned_categories JSONB DEFAULT '[]'::jsonb,
    is_active BOOLEAN DEFAULT true,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Table des adhérents / judokas
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
    photo_path TEXT,
    medical_certif_valid BOOLEAN DEFAULT true,
    registration_date TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Table du planning hebdomadaire
CREATE TABLE IF NOT EXISTS public.scheduled_sessions (
    id TEXT PRIMARY KEY,
    category_id TEXT REFERENCES public.judo_categories(id) ON DELETE SET NULL,
    category_name TEXT NOT NULL,
    group_code TEXT NOT NULL,
    day_of_week_name TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    coach_names JSONB DEFAULT '[]'::jsonb,
    is_recurring_weekly BOOLEAN DEFAULT true,
    series_id TEXT,
    notes TEXT,
    status TEXT DEFAULT 'SCHEDULED',
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Table des séances terminées (Historique Tatami)
CREATE TABLE IF NOT EXISTS public.past_sessions (
    id TEXT PRIMARY KEY,
    category_id TEXT,
    category_name TEXT NOT NULL,
    group_code TEXT NOT NULL,
    date_string TEXT NOT NULL,
    start_time TEXT NOT NULL,
    end_time TEXT NOT NULL,
    coach1_name TEXT,
    coach2_name TEXT,
    present_count INT DEFAULT 0,
    absent_count INT DEFAULT 0,
    present_member_names JSONB DEFAULT '[]'::jsonb,
    absent_member_names JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Table des présences / émargements (Contrainte anti-doublon par jour)
CREATE TABLE IF NOT EXISTS public.attendances (
    id TEXT PRIMARY KEY, -- Format: {memberId}_{dateString}
    member_id BIGINT REFERENCES public.members(id) ON DELETE CASCADE,
    date_string TEXT NOT NULL,
    time_string TEXT NOT NULL,
    timestamp BIGINT NOT NULL,
    check_in_method TEXT DEFAULT 'QR_SCAN',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_member_attendance_per_day UNIQUE (member_id, date_string)
);

-- 7. Journal d'audit des synchronisations et résolutions de conflits
CREATE TABLE IF NOT EXISTS public.sync_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id TEXT NOT NULL,
    entity_name TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    operation_type TEXT NOT NULL,
    resolved_by TEXT DEFAULT 'TIMESTAMP_LWW',
    timestamp TIMESTAMPTZ DEFAULT NOW()
);

-- Index pour accélérer les requêtes incrémentales
CREATE INDEX IF NOT EXISTS idx_members_updated_at ON public.members (updated_at);
CREATE INDEX IF NOT EXISTS idx_attendances_date ON public.attendances (date_string);
CREATE INDEX IF NOT EXISTS idx_attendances_member ON public.attendances (member_id);

-- Row Level Security (RLS)
ALTER TABLE public.judo_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coaches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scheduled_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.past_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendances ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_audit_log ENABLE ROW LEVEL SECURITY;

-- Politiques RLS avec clé publique anon
DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Anon club app access members" ON public.members;
    CREATE POLICY "Anon club app access members" ON public.members FOR ALL USING (true);

    DROP POLICY IF EXISTS "Anon club app access attendances" ON public.attendances;
    CREATE POLICY "Anon club app access attendances" ON public.attendances FOR ALL USING (true);

    DROP POLICY IF EXISTS "Anon club app access past_sessions" ON public.past_sessions;
    CREATE POLICY "Anon club app access past_sessions" ON public.past_sessions FOR ALL USING (true);

    DROP POLICY IF EXISTS "Anon club app access scheduled_sessions" ON public.scheduled_sessions;
    CREATE POLICY "Anon club app access scheduled_sessions" ON public.scheduled_sessions FOR ALL USING (true);

    DROP POLICY IF EXISTS "Anon club app access categories" ON public.judo_categories;
    CREATE POLICY "Anon club app access categories" ON public.judo_categories FOR ALL USING (true);

    DROP POLICY IF EXISTS "Anon club app access coaches" ON public.coaches;
    CREATE POLICY "Anon club app access coaches" ON public.coaches FOR ALL USING (true);

    DROP POLICY IF EXISTS "Anon club app access audit_log" ON public.sync_audit_log;
    CREATE POLICY "Anon club app access audit_log" ON public.sync_audit_log FOR ALL USING (true);
END $$;

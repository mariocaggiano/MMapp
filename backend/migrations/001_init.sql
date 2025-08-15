-- 001_init.sql (short version for dev)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE,
  display_name TEXT,
  role TEXT NOT NULL DEFAULT 'amateur' CHECK (role IN ('amateur','semi_pro','pro','coach','admin')),
  weight_class TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  athlete_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  program_assignment_id UUID,
  date TIMESTAMPTZ NOT NULL,
  duration_min INT NOT NULL CHECK (duration_min > 0),
  intensity_rpe INT CHECK (intensity_rpe BETWEEN 1 AND 10),
  disciplines TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
  notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_sessions_athlete_date ON sessions (athlete_id, date);

CREATE TABLE IF NOT EXISTS weight_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  weight_kg NUMERIC(5,2) NOT NULL,
  UNIQUE(user_id, date)
);

CREATE INDEX IF NOT EXISTS idx_weights_user_date ON weight_entries (user_id, date);

CREATE TABLE IF NOT EXISTS fight_camps (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  pro_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  event_name TEXT NOT NULL,
  opponent TEXT,
  date DATE NOT NULL,
  camp_start DATE NOT NULL,
  target_weight_kg NUMERIC(5,2),
  status TEXT NOT NULL DEFAULT 'planned' CHECK (status IN ('planned','active','completed','cancelled'))
);

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_weekly_stats AS
SELECT
  s.athlete_id AS user_id,
  date_trunc('week', s.date)::date AS week_start,
  SUM(s.duration_min) AS total_minutes,
  SUM(CASE WHEN 'striking' = ANY(s.disciplines) THEN s.duration_min ELSE 0 END) AS striking_min,
  SUM(CASE WHEN 'grappling' = ANY(s.disciplines) THEN s.duration_min ELSE 0 END) AS grappling_min,
  SUM(CASE WHEN 'sparring' = ANY(s.disciplines) THEN s.duration_min ELSE 0 END) AS sparring_min
FROM sessions s
GROUP BY 1,2;

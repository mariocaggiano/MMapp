-- 002_helpers.sql
CREATE OR REPLACE FUNCTION refresh_mv_weekly_stats()
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY mv_weekly_stats;
END $$;

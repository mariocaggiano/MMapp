
import { Injectable } from '@nestjs/common';
import { DbService } from '../db/db.service';

type Overview = {
  totalMinutes: number;
  byDiscipline: { striking: number; grappling: number; sparring: number; conditioning: number };
  streakDays: number;
  adherence: number;
};

@Injectable()
export class StatsService {
  constructor(private db: DbService) {}

  async overview(uid: string, from?: string, to?: string): Promise<Overview> {
    // Total minutes & per-discipline
    const res = await this.db.pool.query(
      `select
         coalesce(sum(duration_min),0) as total,
         coalesce(sum(case when 'striking'=any(disciplines) then duration_min else 0 end),0) as striking,
         coalesce(sum(case when 'grappling'=any(disciplines) then duration_min else 0 end),0) as grappling,
         coalesce(sum(case when 'sparring'=any(disciplines) then duration_min else 0 end),0) as sparring,
         coalesce(sum(case when 'conditioning'=any(disciplines) then duration_min else 0 end),0) as conditioning
       from sessions
       where athlete_id=$1
         and ($2::timestamptz is null or date >= $2::timestamptz)
         and ($3::timestamptz is null or date <= $3::timestamptz)`,
      [uid, from ?? null, to ?? null]
    );
    const row = res.rows[0];
    // Compute streak days (consecutive days with >=1 session ending today)
    const streakRes = await this.db.pool.query(
      `with days as (
         select distinct date::date d
         from sessions where athlete_id=$1
           and ($2::timestamptz is null or date >= $2::timestamptz)
           and ($3::timestamptz is null or date <= $3::timestamptz)
       )
       select coalesce(max(streak),0) as streak from (
         select d, sum(gap) over (order by d) grp, count(*) over () cnt,
                row_number() over (order by d) -
                row_number() over (order by d) as gap,
                1 as one
         from (
           select d, (extract(epoch from d) / 86400)::int - row_number() over (order by d) as gap
           from days
         ) t
       ) s`,
      [uid, from ?? null, to ?? null]
    ).catch(()=>({ rows:[{ streak: 0 }]}));
    const streakDays = Number(streakRes.rows[0]?.streak ?? 0);

    // Adherence: days with >=1 session / total days in range (default 7d)
    let fromD = from ? new Date(from) : new Date(Date.now() - 7*86400000);
    let toD = to ? new Date(to) : new Date();
    const totalDays = Math.max(1, Math.ceil((toD.getTime() - fromD.getTime())/86400000)+1);
    const daysRes = await this.db.pool.query(
      `select count(distinct date::date) as d from sessions where athlete_id=$1
       and ($2::timestamptz is null or date >= $2::timestamptz)
       and ($3::timestamptz is null or date <= $3::timestamptz)`,
      [uid, from ?? null, to ?? null]
    );
    const activeDays = Number(daysRes.rows[0]?.d ?? 0);
    const adherence = activeDays / totalDays;

    return {
      totalMinutes: Number(row.total || 0),
      byDiscipline: {
        striking: Number(row.striking || 0),
        grappling: Number(row.grappling || 0),
        sparring: Number(row.sparring || 0),
        conditioning: Number(row.conditioning || 0),
      },
      streakDays,
      adherence,
    };
  }

  async weekly(uid: string) {
    const res = await this.db.pool.query(
      `select week_start, total_minutes, striking_min, grappling_min, sparring_min
       from mv_weekly_stats where user_id=$1 order by week_start desc limit 26`,
      [uid]
    );
    return res.rows;
  }
}

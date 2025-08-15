
import { Injectable } from '@nestjs/common';
import { DbService } from '../db/db.service';

@Injectable()
export class SessionsService {
  constructor(private db: DbService) {}

  async create(uid: string, dto: any) {
    const res = await this.db.pool.query(
      `insert into sessions(athlete_id, date, duration_min, intensity_rpe, disciplines, notes, program_assignment_id)
       values($1,$2,$3,$4,$5,$6,$7) returning *`,
      [uid, dto.date, dto.durationMin, dto.intensityRpe ?? null, dto.disciplines ?? [], dto.notes ?? null, dto.programAssignmentId ?? null]
    );
    return res.rows[0];
  }

  async list(uid: string, from?: string, to?: string, limit=50, cursor?: string) {
    let params:any[]=[uid]; let where = 'athlete_id=$1';
    if (from) { params.push(from); where += " and date >= ${'$'}{params.length}"; }
    if (to) { params.push(to); where += " and date <= ${'$'}{params.length}"; }
    let sql = `select * from sessions where ${where} order by date desc limit ${limit}`;
    const res = await this.db.pool.query(sql, params);
    return res.rows;
  }

  async update(uid: string, id: string, dto: any) {
    const res = await this.db.pool.query(
      `update sessions set date=coalesce($3,date), duration_min=coalesce($4,duration_min),
        intensity_rpe=coalesce($5,intensity_rpe), disciplines=coalesce($6,disciplines),
        notes=coalesce($7,notes) where id=$2 and athlete_id=$1 returning *`,
      [uid, id, dto.date ?? null, dto.durationMin ?? null, dto.intensityRpe ?? null, dto.disciplines ?? null, dto.notes ?? null]
    );
    return res.rows[0];
  }

  async remove(uid: string, id: string) {
    await this.db.pool.query('delete from sessions where id=$1 and athlete_id=$2', [id, uid]);
  }
}

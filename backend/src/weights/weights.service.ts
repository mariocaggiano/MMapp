import { Injectable } from '@nestjs/common';
import { DbService } from '../db/db.service';

@Injectable()
export class WeightsService {
  constructor(private db: DbService) {}

  async insert(uid: string, date: string, weightKg: number) {
    const sql = `insert into weight_entries(user_id, date, weight_kg) values($1,$2,$3)
      on conflict (user_id, date) do update set weight_kg=excluded.weight_kg returning *`;
    const res = await this.db.pool.query(sql, [uid, date, weightKg]);
    return res.rows[0];
  }

  async list(uid: string, days: number = 30) {
    const sql = `select * from weight_entries where user_id=$1 and date >= current_date - $2::int
      order by date desc`;
    const res = await this.db.pool.query(sql, [uid, days]);
    return res.rows;
  }
}

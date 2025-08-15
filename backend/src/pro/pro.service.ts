import { Injectable } from '@nestjs/common';
import { DbService } from '../db/db.service';

@Injectable()
export class ProService {
  constructor(private db: DbService) {}

  async createCamp(uid: string, body: any) {
    const res = await this.db.pool.query(
      `insert into fight_camps(pro_id, event_name, opponent, date, camp_start, target_weight_kg, status)
       values($1,$2,$3,$4,$5,$6,'planned') returning *`,
      [uid, body.eventName, body.opponent ?? null, body.date, body.campStart, body.targetWeightKg ?? null]
    );
    return res.rows[0];
  }

  async current(uid: string) {
    const res = await this.db.pool.query(
      `select * from fight_camps where pro_id=$1 and status in ('planned','active')
       order by date asc limit 1`, [uid]
    );
    return res.rows[0] ?? null;
  }
}

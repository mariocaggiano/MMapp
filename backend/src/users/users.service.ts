
import { Injectable } from '@nestjs/common';
import { DbService } from '../db/db.service';

@Injectable()
export class UsersService {
  constructor(private db: DbService) {}

  async ensureUser(uid: string, email: string | null | undefined) {
    // Try find by id, else insert minimal
    const q = await this.db.pool.query('select * from users where id=$1', [uid]);
    if (q.rows.length) return q.rows[0];
    const display = email?.split('@')[0] || 'user';
    await this.db.pool.query('insert into users(id, email, display_name, role) values($1,$2,$3,$4) on conflict do nothing', [uid, email, display, 'amateur']);
    const q2 = await this.db.pool.query('select * from users where id=$1', [uid]);
    return q2.rows[0];
  }

  async update(uid: string, data: { displayName?: string; weightClass?: string }) {
    await this.db.pool.query('update users set display_name=coalesce($2, display_name), weight_class=coalesce($3, weight_class) where id=$1', [uid, data.displayName ?? null, data.weightClass ?? null])
  }
}

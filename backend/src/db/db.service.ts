import { Injectable, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import pg from 'pg';

@Injectable()
export class DbService implements OnModuleInit, OnModuleDestroy {
  pool!: pg.Pool;

  async onModuleInit() {
    const url = process.env.DATABASE_URL;
    if (!url) throw new Error('DATABASE_URL not set');
    this.pool = new pg.Pool({ connectionString: url });
    await this.pool.query('select 1');
  }

  async onModuleDestroy() {
    await this.pool.end();
  }
}

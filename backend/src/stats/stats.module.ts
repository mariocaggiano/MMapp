
import { Module } from '@nestjs/common';
import { StatsService } from './stats.service';
import { StatsController } from './stats.controller';
import { DbModule } from '../db/db.module';

@Module({ imports: [DbModule], providers: [StatsService], controllers: [StatsController] })
export class StatsModule {}

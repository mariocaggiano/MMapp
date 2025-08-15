import { Module } from '@nestjs/common';
import { DbModule } from './db/db.module';
import { UsersModule } from './users/users.module';
import { SessionsModule } from './sessions/sessions.module';
import { WeightsModule } from './weights/weights.module';
import { ProModule } from './pro/pro.module';
import { StatsModule } from './stats/stats.module';
import { MediaModule } from './media/media.module';
import { HealthModule } from './health/health.module';

@Module({
  imports: [DbModule, UsersModule, SessionsModule, WeightsModule, ProModule, StatsModule, MediaModule, HealthModule],
})
export class AppModule {}

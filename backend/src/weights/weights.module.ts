import { Module } from '@nestjs/common';
import { WeightsService } from './weights.service';
import { WeightsController } from './weights.controller';
import { DbModule } from '../db/db.module';
import { UsersModule } from '../users/users.module';

@Module({ imports: [DbModule, UsersModule], providers: [WeightsService], controllers: [WeightsController] })
export class WeightsModule {}

import { Module } from '@nestjs/common';
import { ProController } from './pro.controller';
import { ProService } from './pro.service';
import { DbModule } from '../db/db.module';
import { UsersModule } from '../users/users.module';

@Module({ imports: [DbModule, UsersModule], controllers: [ProController], providers: [ProService] })
export class ProModule {}

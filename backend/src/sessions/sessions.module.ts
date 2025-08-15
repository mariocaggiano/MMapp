import { Module } from '@nestjs/common';
import { SessionsService } from './sessions.service';
import { SessionsController } from './sessions.controller';
import { DbModule } from '../db/db.module';
import { UsersModule } from '../users/users.module';

@Module({ imports: [DbModule, UsersModule], providers: [SessionsService], controllers: [SessionsController] })
export class SessionsModule {}

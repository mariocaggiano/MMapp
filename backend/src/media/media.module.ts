
import { Module } from '@nestjs/common';
import { MediaController } from './media.controller';
import { MediaService } from './media.service';
import { DbModule } from '../db/db.module';

@Module({ imports: [DbModule], controllers: [MediaController], providers: [MediaService] })
export class MediaModule {}

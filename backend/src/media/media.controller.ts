
import { Controller, Post, Body, Get, Param, UseGuards } from '@nestjs/common';
import { FirebaseAuthGuard } from '../common/guards/firebase-auth.guard';
import { CurrentUser } from '../common/decorators/user.decorator';
import { MediaService } from './media.service';

@UseGuards(FirebaseAuthGuard)
@Controller()
export class MediaController {
  constructor(private media: MediaService) {}

  @Post('media/presign')
  presign(@CurrentUser() user: any, @Body() body: any) {
    return this.media.presign(user.uid, body);
  }

  @Post('media/complete')
  complete(@CurrentUser() user: any, @Body() body: any) {
    return this.media.complete(user.uid, body);
  }

  @Get('sessions/:id/media')
  list(@CurrentUser() user: any, @Param('id') id: string) {
    return this.media.listForSession(user.uid, id);
  }
}

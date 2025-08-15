
import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { FirebaseAuthGuard } from '../common/guards/firebase-auth.guard';
import { CurrentUser } from '../common/decorators/user.decorator';
import { StatsService } from './stats.service';

@UseGuards(FirebaseAuthGuard)
@Controller('stats')
export class StatsController {
  constructor(private stats: StatsService) {}

  @Get('overview')
  async overview(@CurrentUser() user: any, @Query('from') from?: string, @Query('to') to?: string) {
    return await this.stats.overview(user.uid, from, to);
  }

  @Get('weekly')
  async weekly(@CurrentUser() user: any) {
    return await this.stats.weekly(user.uid);
  }
}

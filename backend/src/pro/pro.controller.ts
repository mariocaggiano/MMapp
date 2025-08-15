import { Controller, Post, Get, Body, UseGuards } from '@nestjs/common';
import { FirebaseAuthGuard } from '../common/guards/firebase-auth.guard';
import { CurrentUser } from '../common/decorators/user.decorator';
import { ProService } from './pro.service';

@UseGuards(FirebaseAuthGuard)
@Controller('pro/fight-camps')
export class ProController {
  constructor(private pro: ProService) {}

  @Post()
  async create(@CurrentUser() user: any, @Body() body: any) {
    return await this.pro.createCamp(user.uid, body);
  }

  @Get('current')
  async current(@CurrentUser() user: any) {
    return await this.pro.current(user.uid);
  }
}

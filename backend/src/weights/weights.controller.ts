
import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { FirebaseAuthGuard } from '../common/guards/firebase-auth.guard';
import { CurrentUser } from '../common/decorators/user.decorator';
import { WeightsService } from './weights.service';

@UseGuards(FirebaseAuthGuard)
@Controller('weights')
export class WeightsController {
  constructor(private weights: WeightsService) {}

  @Post()
  async add(@CurrentUser() user: any, @Body() body: { date: string; weightKg: number }) {
    return await this.weights.insert(user.uid, body.date, body.weightKg);
  }

  @Get()
  async list(@CurrentUser() user: any, @Query('range') rng?: string) {
    const days = rng && rng.endsWith('d') ? parseInt(rng.slice(0,-1)) : 30;
    return await this.weights.list(user.uid, days);
  }
}

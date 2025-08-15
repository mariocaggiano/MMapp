import { Controller, Get, Post, Patch, Delete, Body, Query, Param, UseGuards } from '@nestjs/common';
import { FirebaseAuthGuard } from '../common/guards/firebase-auth.guard';
import { CurrentUser } from '../common/decorators/user.decorator';
import { SessionsService } from './sessions.service';

class CreateSessionDto {
  date!: string; // ISO date-time
  durationMin!: number;
  intensityRpe?: number;
  disciplines?: string[];
  notes?: string;
  programAssignmentId?: string;
}

@UseGuards(FirebaseAuthGuard)
@Controller('sessions')
export class SessionsController {
  constructor(private sessions: SessionsService) {}

  @Post()
  async create(@CurrentUser() user: any, @Body() dto: CreateSessionDto) {
    return await this.sessions.create(user.uid, dto);
  }

  @Get()
  async list(@CurrentUser() user: any, @Query('from') from?: string, @Query('to') to?: string) {
    return await this.sessions.list(user.uid, from, to);
  }

  @Patch(':id')
  async update(@CurrentUser() user: any, @Param('id') id: string, @Body() dto: Partial<CreateSessionDto>) {
    return await this.sessions.update(user.uid, id, dto);
  }

  @Delete(':id')
  async remove(@CurrentUser() user: any, @Param('id') id: string) {
    await this.sessions.remove(user.uid, id);
    return { ok: true };
  }
}

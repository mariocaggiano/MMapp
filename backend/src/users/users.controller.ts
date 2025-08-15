import { Controller, Get, Patch, Body, UseGuards } from '@nestjs/common';
import { FirebaseAuthGuard } from '../common/guards/firebase-auth.guard';
import { CurrentUser } from '../common/decorators/user.decorator';
import { UsersService } from './users.service';

class UpdateMeDto {
  displayName?: string;
  weightClass?: string;
}

@UseGuards(FirebaseAuthGuard)
@Controller('me')
export class UsersController {
  constructor(private users: UsersService) {}

  @Get()
  async getMe(@CurrentUser() user: any) {
    const row = await this.users.ensureUser(user.uid, user.email);
    return {
      id: row.id,
      email: row.email,
      displayName: row.display_name,
      role: row.role,
      weightClass: row.weight_class,
      createdAt: row.created_at,
    };
  }

  @Patch()
  async patchMe(@CurrentUser() user: any, @Body() dto: UpdateMeDto) {
    await this.users.ensureUser(user.uid, user.email);
    await this.users.update(user.uid, dto as any);
    return { ok: true };
  }
}

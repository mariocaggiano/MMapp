
import { Injectable } from '@nestjs/common';
import { DbService } from '../db/db.service';
import { randomUUID } from 'crypto';

@Injectable()
export class MediaService {
  constructor(private db: DbService) {}

  async presign(ownerId: string, body: { fileName: string; mime: string; sessionId?: string; private?: boolean }) {
    const key = `media/${ownerId}/${Date.now()}-${body.fileName}`;
    // In dev we return a dummy upload URL; in prod integrate S3
    return {
      uploadUrl: 'https://example.invalid/upload', // TODO: replace with S3 pre-signed URL
      s3Key: key,
      fields: {},
    };
  }

  async complete(ownerId: string, body: { s3Key: string; type?: 'image'|'video'; sessionId?: string; private?: boolean }) {
    const type = body.type ?? (body.s3Key.endsWith('.mp4') ? 'video' : 'image');
    const res = await this.db.pool.query(
      `insert into media_assets(owner_id, session_id, type, s3_key, mime, is_private)
       values($1,$2,$3,$4,$5,$6) returning *`,
      [ownerId, body.sessionId ?? null, type, body.s3Key, null, body.private ?? true]
    );
    return res.rows[0];
  }

  async listForSession(uid: string, sessionId: string) {
    const res = await this.db.pool.query(
      `select id, owner_id, session_id, type, s3_key, is_private, created_at
       from media_assets
       where session_id=$1 and owner_id=$2
       order by created_at desc`, [sessionId, uid]
    );
    return res.rows;
  }
}

import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';
import * as admin from 'firebase-admin';

function initFirebase() {
  if (process.env.NO_AUTH === 'true') return;
  if (admin.apps.length) return;
  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');
  if (!projectId || !clientEmail || !privateKey) {
    throw new Error('Firebase credentials missing. Set NO_AUTH=true for local dev.');
  }
  admin.initializeApp({
    credential: admin.credential.cert({ projectId, clientEmail, privateKey } as any),
  });
}

@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  constructor() {
    initFirebase();
  }
  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const req = ctx.switchToHttp().getRequest();
    const auth = req.headers['authorization'] as string | undefined;
    if (!auth || !auth.startsWith('Bearer ')) throw new UnauthorizedException('Missing bearer token');
    const token = auth.slice(7);

    if (process.env.NO_AUTH === 'true') {
      // dev mode: allow, attach user from header or default
      req.user = {
        uid: req.headers['x-user-id'] || '00000000-0000-0000-0000-000000000001',
        email: req.headers['x-user-email'] || null,
      };
      return true;
    }

    const decoded = await admin.auth().verifyIdToken(token);
    req.user = { uid: decoded.uid, email: decoded.email };
    return true;
  }
}

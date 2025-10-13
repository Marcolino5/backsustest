#!/usr/bin/env bash
set -e

# Apply migrations first (DB must exist)
npx prisma migrate deploy

# Then generate Prisma client
npx prisma generate

# Run seed script (compiled JS)
npx ts-node src/auth/seed.ts || {
  echo "Seed script failed, continuing..."
}

# Start app
npm run start:prod
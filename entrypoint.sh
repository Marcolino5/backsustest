#!/usr/bin/env bash
set -e  # exit if any command fails

echo "1️⃣ Deploying migrations..."
npx prisma migrate deploy

echo "2️⃣ Regenerating Prisma client after migrations..."
npx prisma generate

echo "3️⃣ Running seed script..."
node ./dist/src/auth/seed.js || echo "Seed failed, continuing..."

echo "4️⃣ Starting NestJS application..."
npm run start:prod
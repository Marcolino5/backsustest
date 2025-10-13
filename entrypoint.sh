#!/usr/bin/env bash
set -e

# 1️⃣ Generate Prisma client
npx prisma generate

# 2️⃣ Apply migrations
npx prisma migrate deploy

# 3️⃣ Run your seed script (compiled JS)
# Adjust the path if needed. For NestJS: dist/src/auth/seed.js
node ./dist/src/auth/seed.js || {
  echo "Seed script failed. Continuing startup..."
}

# 4️⃣ Start your application
npm start
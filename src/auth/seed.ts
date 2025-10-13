import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Default admin credentials (change these for production).
  // Create a canonical admin account for local dev.
  const email = process.env.SEED_ADMIN_EMAIL ?? 'admin@teste.com';
  const senha = process.env.SEED_ADMIN_SENHA ?? 'admin';
  const admin = true;

  // Remove any previously created admin placeholders and blank-email users
  await prisma.user.deleteMany({
    where: { email: { in: ['admin', 'admin@teste.com', ''] } },
  });

  // Use upsert so running the script multiple times is safe
  const user = await prisma.user.upsert({
    where: { email },
    update: { senha, admin },
    create: { email, senha, admin },
  });

  console.log('✅ Default admin upserted:', user);
}

main()
  .catch((e) => console.error(e))
  .finally(async () => {
    await prisma.$disconnect();
  });

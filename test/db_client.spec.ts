import { PrismaService } from "../src/services/prisma.service";
import { Client } from "@prisma/client";

describe('Client Model', () => {
  const prisma = new PrismaService();

  it('should select test client', async () => {
    const client: Client = await prisma.client.findUnique({
      where: {
        cnes: 123,
      }
    });

    expect(client).toBeDefined();

    expect(client.cnpj).toBe(1234);
  });

  it('should delete test client', async () => {
    await prisma.client.delete({
      where: {
        cnes: 123,
      }
    });

    const client: Client = await prisma.client.findUnique({
      where: {
        cnes: 123,
      }
    });

    expect(client).toBeNull();
  });

  it('should recreate the test client', async () => {
    await prisma.client.create({
      data: {
        cnes: 123,
        cnpj: 1234,
        state: 'DF',
      }
    });

    const client: Client = await prisma.client.findUnique({
      where: {
        cnes: 123,
      }
    });

    expect(client).toBeDefined();

    expect(client.cnpj).toBe(1234);

  })
});

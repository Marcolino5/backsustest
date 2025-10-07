/*
  Warnings:

  - The primary key for the `Client` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `snes` on the `Client` table. All the data in the column will be lost.
  - You are about to drop the column `hospital_snes` on the `Procedure` table. All the data in the column will be lost.
  - Added the required column `cnes` to the `Client` table without a default value. This is not possible if the table is not empty.
  - Added the required column `hospital_cnes` to the `Procedure` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "Procedure" DROP CONSTRAINT "Procedure_hospital_snes_fkey";

-- AlterTable
ALTER TABLE "Client" DROP CONSTRAINT "Client_pkey",
DROP COLUMN "snes",
ADD COLUMN     "cnes" INTEGER NOT NULL,
ADD CONSTRAINT "Client_pkey" PRIMARY KEY ("cnes");

-- AlterTable
ALTER TABLE "Procedure" DROP COLUMN "hospital_snes",
ADD COLUMN     "hospital_cnes" INTEGER NOT NULL;

-- CreateTable
CREATE TABLE "Report" (
    "id" SERIAL NOT NULL,
    "pdf" BYTEA NOT NULL,
    "data_created" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "client_cnes" INTEGER NOT NULL,

    CONSTRAINT "Report_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "Procedure" ADD CONSTRAINT "Procedure_hospital_cnes_fkey" FOREIGN KEY ("hospital_cnes") REFERENCES "Client"("cnes") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Report" ADD CONSTRAINT "Report_client_cnes_fkey" FOREIGN KEY ("client_cnes") REFERENCES "Client"("cnes") ON DELETE RESTRICT ON UPDATE CASCADE;

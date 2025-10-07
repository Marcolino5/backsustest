-- CreateTable
CREATE TABLE "Client" (
    "snes" INTEGER NOT NULL,
    "cnpj" INTEGER NOT NULL,
    "hire_date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "state" TEXT NOT NULL,

    CONSTRAINT "Client_pkey" PRIMARY KEY ("snes")
);

-- CreateTable
CREATE TABLE "Procedure" (
    "aih" INTEGER NOT NULL,
    "date_proc" TIMESTAMP(3) NOT NULL,
    "val_h" INTEGER NOT NULL DEFAULT 0,
    "val_u" INTEGER NOT NULL DEFAULT 0,
    "val_p" INTEGER NOT NULL DEFAULT 0,
    "hospital_snes" INTEGER NOT NULL,
    "procedureTypeid" INTEGER NOT NULL,

    CONSTRAINT "Procedure_pkey" PRIMARY KEY ("aih")
);

-- CreateTable
CREATE TABLE "ProcedureType" (
    "id" SERIAL NOT NULL,
    "valTunep" DOUBLE PRECISION NOT NULL,
    "description" TEXT,

    CONSTRAINT "ProcedureType_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Client_cnpj_key" ON "Client"("cnpj");

-- AddForeignKey
ALTER TABLE "Procedure" ADD CONSTRAINT "Procedure_hospital_snes_fkey" FOREIGN KEY ("hospital_snes") REFERENCES "Client"("snes") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Procedure" ADD CONSTRAINT "Procedure_procedureTypeid_fkey" FOREIGN KEY ("procedureTypeid") REFERENCES "ProcedureType"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

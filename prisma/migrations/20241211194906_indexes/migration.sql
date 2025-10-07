-- CreateIndex
CREATE INDEX "Procedure_hospital_cnes_procedureTypeid_idx" ON "Procedure"("hospital_cnes", "procedureTypeid");

-- CreateIndex
CREATE INDEX "Report_client_cnes_pdf_idx" ON "Report"("client_cnes", "pdf");

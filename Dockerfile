# ---------- STAGE 1: Builder ----------
FROM node:22-bullseye-slim AS builder

WORKDIR /app

# Instala dependências do sistema
RUN apt-get update && \
    apt-get install -y python3 python3-pip make git curl gcc build-essential \
                       texlive-latex-recommended texlive-xetex unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copia arquivos de dependências do Node
COPY package*.json ./
RUN npm install --legacy-peer-deps

# Copia tsconfig para build TypeScript
COPY tsconfig.json ./

# Copia o restante do código
COPY . .

# Instala pacotes Python
RUN pip3 install pandas numpy matplotlib dbfread simpledbf

# Gera cliente Prisma
RUN npx prisma generate

# Build TypeScript (NestJS)
RUN npm run build

# ---------- GET & BUILD EXECUTÁVEIS C ----------
# Cria pasta para binários
RUN mkdir -p /app/scripts/susprocessing/exes

# Clona e compila blast-dbf
RUN git clone https://github.com/eaglebh/blast-dbf.git /tmp/blast-dbf
RUN gcc /tmp/blast-dbf/blast-dbf.c -o /app/scripts/susprocessing/exes/blast-dbf

# Clona e compila dbc2csv
RUN git clone https://github.com/rmxvrelease/dbc2csv.git /tmp/dbc2csv
RUN cd /tmp/dbc2csv && make
RUN cp /tmp/dbc2csv/dbc2csv /app/scripts/susprocessing/exes/DBF2CSV

# ---------- STAGE 2: Runtime ----------
FROM node:22-bullseye-slim

WORKDIR /app

# Instala dependências mínimas
RUN apt-get update && \
    apt-get install -y python3 python3-pip make texlive-latex-recommended texlive-xetex git curl unzip gcc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copia arquivos do builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/tsconfig.json ./
COPY --from=builder /app/scripts ./scripts

# Instala pacotes Python
RUN pip3 install pandas numpy matplotlib dbfread simpledbf

# Copia entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expõe porta
EXPOSE 8080

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
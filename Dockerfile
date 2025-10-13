# ---------- STAGE 1: Builder ----------
FROM node:22-bullseye-slim AS builder

WORKDIR /app

# Install system dependencies and C build tools
RUN apt-get update && \
    apt-get install -y python3 python3-pip make git curl gcc \
                       texlive-latex-recommended texlive-xetex unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Node dependencies for caching
COPY package*.json ./
RUN npm install --legacy-peer-deps

COPY tsconfig.json ./
COPY . .

# Create folder for executables
RUN mkdir -p /app/scripts/susprocessing/exes

# ---------- Compile C executables ----------

# 1. blast-dbf (Makefile)
RUN git clone https://github.com/eaglebh/blast-dbf.git /tmp/blast-dbf && \
    cd /tmp/blast-dbf && \
    make && \
    cp blast-dbf /app/scripts/susprocessing/exes/blast-dbf

# 2. DBF2CSV (.c only)
RUN git clone https://github.com/rmxvrelease/dbc2csv.git /tmp/dbc2csv && \
    gcc /tmp/dbc2csv/DBF2CSV.c -o /app/scripts/susprocessing/exes/DBF2CSV

# 3. unzip (system version)
RUN ln -s /usr/bin/unzip /app/scripts/susprocessing/exes/unzip

# Give execute permissions
RUN chmod +x /app/scripts/susprocessing/exes/*

# Python dependencies
RUN pip3 install pandas numpy matplotlib

# Generate Prisma client
RUN npx prisma generate

# Build TypeScript (NestJS)
RUN npm run build

# ---------- STAGE 2: Runtime ----------
FROM node:22-bullseye-slim

WORKDIR /app

# Install minimal runtime dependencies
RUN apt-get update && \
    apt-get install -y python3 python3-pip make git curl gcc \
                       texlive-latex-recommended texlive-xetex unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy built artifacts from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/tsconfig.json ./
COPY --from=builder /app/scripts /app/scripts

# Python dependencies in runtime
RUN pip3 install pandas numpy matplotlib

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
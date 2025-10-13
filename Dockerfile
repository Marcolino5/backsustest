# ---------- STAGE 1: Builder ----------
FROM node:22-bullseye-slim AS builder

WORKDIR /app

# Install system dependencies (including build tools for C)
RUN apt-get update && \
    apt-get install -y python3 python3-pip make git curl gcc \
                       texlive-latex-recommended texlive-xetex && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Node dependency files for caching
COPY package*.json ./
RUN npm install --legacy-peer-deps

COPY tsconfig.json ./
COPY . .

# ---------- Compile the C executables ----------
RUN mkdir -p /app/scripts/susprocessing/exes

# 1. blast-dbf
RUN git clone https://github.com/eaglebh/blast-dbf.git /tmp/blast-dbf && \
    cd /tmp/blast-dbf && \
    make && \
    cp blast-dbf /app/scripts/susprocessing/exes/blast-dbf

# 2. dbc2csv
RUN git clone https://github.com/rmxvrelease/dbc2csv.git /tmp/dbc2csv && \
    cd /tmp/dbc2csv && \
    gcc -o DBF2CSV dbc2csv.c && \
    cp DBF2CSV /app/scripts/susprocessing/exes/DBF2CSV

# 3. unzip (use system unzip for Linux)
RUN ln -s /usr/bin/unzip /app/scripts/susprocessing/exes/unzip

# Python dependencies
RUN pip3 install pandas numpy matplotlib

# Generate Prisma client
RUN npx prisma generate

# Build TypeScript
RUN npm run build


# ---------- STAGE 2: Runtime ----------
FROM node:22-bullseye-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y python3 python3-pip make git curl \
                       texlive-latex-recommended texlive-xetex unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy compiled artifacts
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/scripts /app/scripts
COPY --from=builder /app/tsconfig.json ./

RUN pip3 install pandas numpy matplotlib

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
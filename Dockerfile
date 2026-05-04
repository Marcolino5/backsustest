# ---------- STAGE 1: Builder ----------
FROM node:22-bullseye-slim AS builder
 
WORKDIR /app

# Install system dependencies and build tools + R
RUN apt-get update && \
    apt-get install -y python3 python3-pip make git curl gcc \
                       texlive-latex-recommended texlive-xetex unzip \
                       r-base r-base-dev \
                       libbz2-dev zlib1g-dev liblzma-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install read.dbc (R)
RUN Rscript -e "install.packages('read.dbc', repos='https://cloud.r-project.org')"

# Node dependencies caching
COPY package*.json ./
RUN npm install --legacy-peer-deps

COPY tsconfig.json ./
COPY . .

# Create folder for executables
RUN mkdir -p /app/scripts/susprocessing/exes

# ---------- Compile C executables ----------

# 1. blast-dbf (get source files via curl)
RUN curl -L -o /tmp/blast.c https://raw.githubusercontent.com/eaglebh/blast-dbf/master/blast.c && \
    curl -L -o /tmp/blast.h https://raw.githubusercontent.com/eaglebh/blast-dbf/master/blast.h && \
    curl -L -o /tmp/blast-dbf.c https://raw.githubusercontent.com/eaglebh/blast-dbf/master/blast-dbf.c && \
    cd /tmp && \
    gcc -o /app/scripts/susprocessing/exes/blast-dbf blast.c blast-dbf.c

# 2. DBF2CSV (get source via curl)
RUN curl -L -o /tmp/DBF2CSV.c https://raw.githubusercontent.com/rmxvrelease/dbc2csv/master/DBF2CSV.c && \
    gcc /tmp/DBF2CSV.c -o /app/scripts/susprocessing/exes/DBF2CSV

# 3. unzip (system binary)
RUN ln -s /usr/bin/unzip /app/scripts/susprocessing/exes/unzip

# Make executables runnable
RUN chmod +x /app/scripts/susprocessing/exes/*

# Python dependencies
RUN pip3 install pandas numpy matplotlib

# Prisma client
RUN npx prisma generate

# Build TypeScript (NestJS)
RUN npm run build

# ---------- STAGE 2: Runtime ----------
FROM node:22-bullseye-slim

WORKDIR /app

# Minimal runtime dependencies + R
RUN apt-get update && \
    apt-get install -y python3 python3-pip make git curl gcc \
                       texlive-latex-recommended texlive-xetex unzip \
                       r-base \
                       libbz2-dev zlib1g-dev liblzma-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install read.dbc (R)
RUN Rscript -e "install.packages('read.dbc', repos='https://cloud.r-project.org')"

# Copy built artifacts
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

# ---------- STAGE 1: Builder ----------
FROM node:22-bullseye-slim AS builder

WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y python3 python3-pip make git curl \
                       texlive-latex-recommended texlive-xetex && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Node dependency files for caching
COPY package*.json ./
RUN npm install --legacy-peer-deps

# Copy tsconfig.json for TypeScript build
COPY tsconfig.json ./

# Copy source code (excluding scripts)
COPY . .

# Explicitly copy scripts folder to /app/scripts
COPY scripts /app/scripts

# Install Python packages
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
    apt-get install -y python3 python3-pip make \
                       texlive-latex-recommended texlive-xetex git curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy built artifacts from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/tsconfig.json ./

# Copy scripts folder to runtime image
COPY --from=builder /app/scripts /app/scripts

# Install Python packages in runtime
RUN pip3 install pandas numpy matplotlib

# Copy entrypoint and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose NestJS port
EXPOSE 8080

# Entrypoint runs migrations, seed, Python scripts, and starts app
ENTRYPOINT ["/entrypoint.sh"]
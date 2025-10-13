# ---------- STAGE 1: Builder ----------
FROM node:22-bullseye-slim AS builder

WORKDIR /app

# Install system dependencies for build
RUN apt-get update && \
    apt-get install -y python3 python3-pip make git curl \
                       texlive-latex-recommended texlive-xetex && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Node dependencies files for caching
COPY package*.json ./

# Install Node dependencies
RUN npm install

# Copy source code
COPY . .

# Install Python packages
COPY requirements.txt ./
RUN pip3 install -r requirements.txt

# Generate Prisma client for TypeScript build
RUN npx prisma generate

# Build TypeScript code (NestJS)
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
COPY --from=builder /app/requirements.txt ./

# Install Python packages in runtime image
RUN pip3 install -r requirements.txt

# Copy entrypoint and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose NestJS port
EXPOSE 8080

# Entrypoint runs migrations, seed, Python scripts, and starts app
ENTRYPOINT ["/entrypoint.sh"]
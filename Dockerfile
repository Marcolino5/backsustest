# Base image
FROM ubuntu:latest

# Set working directory
WORKDIR /app

# Install system dependencies, Node 22, Python, LaTeX, make
RUN apt-get update && \
    apt-get install -y curl gnupg git python3 python3-pip make \
                       texlive-latex-recommended texlive-xetex && \
    curl -sL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Verify Node and npm
RUN node -v && npm -v && python3 --version && pip3 --version

# Copy dependency files first for caching
COPY package*.json ./

# Install Node dependencies
RUN npm install

# Copy the rest of the source code
COPY . .

# Install Python packages via pip
# Add any other packages you need here
RUN pip3 install pandas numpy matplotlib

# Generate Prisma client for TypeScript build
RUN npx prisma generate

# Build TypeScript code (NestJS)
RUN npm run build

# Copy entrypoint and make executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose NestJS port
EXPOSE 8080

# Entrypoint runs migrations, seed, Python scripts, and starts app
ENTRYPOINT ["/entrypoint.sh"]
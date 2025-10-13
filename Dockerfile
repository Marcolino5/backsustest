# Use official Node image
FROM node:20

# Set working directory
WORKDIR /app

# Copy dependency files first (for caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the source code
COPY . .

# Expose app port
EXPOSE 8080

# Copy entrypoint script and make it executable inside image
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use entrypoint to run prisma generate, migrate, seed, then start app
ENTRYPOINT ["/entrypoint.sh"]
FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y curl gnupg git
RUN apt-get install -y python3 python3-pandas
RUN apt-get install -y texlive-latex-recommended texlive-xetex
RUN apt-get install -y make

RUN curl -sL https://deb.nodesource.com/setup_22.x | bash -
RUN apt-get install -y nodejs
RUN node -v && npm -v

# 2️⃣ Set working directory
WORKDIR /app

# 3️⃣ Copy dependency files first for caching
COPY package*.json ./

# 4️⃣ Install dependencies (including devDependencies for TS build)
RUN npm install

# 5️⃣ Copy the rest of the source code
COPY . .

# 6️⃣ Generate Prisma client for TypeScript build
RUN npx prisma generate

# 7️⃣ Build TypeScript code
RUN npm run build

# 8️⃣ Expose app port
EXPOSE 8080

# 9️⃣ Copy entrypoint script and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 🔟 Use entrypoint to run migrations, seed, and start app
ENTRYPOINT ["/entrypoint.sh"]
# Usa uma imagem oficial do Node
FROM node:20

# Define o diretório de trabalho
WORKDIR /app

# Copia os arquivos de dependências primeiro (para cache eficiente)
COPY package*.json ./

# Instala as dependências
RUN npm install

# Copia o restante do código
COPY . .

# Executa as migrações e gera o Prisma Client
RUN npx prisma generate
RUN npx prisma migrate dev --name "init"

# Expõe a porta do app (troque se for diferente)
EXPOSE 3001

# Comando padrão para iniciar a aplicação
CMD ["npm", "start"]
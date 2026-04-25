FROM node:22-slim

WORKDIR /app

RUN apt-get update -y && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm install

COPY . .

# Generate Prisma Client
RUN npx prisma generate

EXPOSE 3000 9220 3001

CMD ["sh", "-c", "mkdir -p /app/data && npx prisma db push --accept-data-loss && npm start"]

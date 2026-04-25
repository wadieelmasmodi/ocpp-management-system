FROM node:22-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Environment variables needed for build can be set here or via Coolify
ENV NEXT_PUBLIC_API_URL=https://evcharging.enegum.earth/api

RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]

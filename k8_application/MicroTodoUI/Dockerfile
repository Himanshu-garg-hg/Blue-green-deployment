FROM node:16.20.2-alpine3.18 as base
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:1.25.2-alpine
COPY --from=Base /app/build /usr/share/nginx/html
EXPOSE 80



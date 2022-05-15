FROM node:16.15-alpine as client-build

WORKDIR /client
COPY package.json ./

RUN npm install
COPY . .

RUN npm run build
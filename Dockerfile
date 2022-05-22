FROM node:16.15-alpine as client-stage

WORKDIR /client
COPY /client/package*.json ./

RUN npm install
COPY ./client /client

RUN npm run build


FROM nginx as production-stage

COPY ./default.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /client/dist
COPY --from=client-stage /client/dist /client/dist

ENTRYPOINT [ "nginx-entrypoint.sh" ]
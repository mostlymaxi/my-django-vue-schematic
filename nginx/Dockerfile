FROM nginx as production-stage

COPY ./default.conf /etc/nginx/conf.d/default.conf

RUN mkdir -p /client/dist
COPY ./nginx-entrypoint.sh .

ENTRYPOINT [ "sh", "/nginx-entrypoint.sh" ]
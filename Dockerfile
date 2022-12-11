FROM alpine:latest

ARG baseurl
ENV BASEURL=$baseurl

EXPOSE 80

RUN apk add bash curl tcpdump libcap

COPY --chown=nobody:nobody blog blog

# get the hugo tooling into the container
COPY --chown=nobody:nobody hugo_tools/hugo hugo

RUN setcap cap_net_bind_service+ip hugo

USER nobody
WORKDIR blog
ENTRYPOINT ../hugo  --appendPort "false" --port "80" --bind "0.0.0.0" --baseURL "${BASEURL}" --environment "production" server

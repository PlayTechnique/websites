FROM nginx:latest
COPY blog blog

# get the hugo tooling into the container
COPY hugo_tools/hugo hugo
WORKDIR blog
RUN ../hugo

RUN cp -r public/* /usr/share/nginx/html/

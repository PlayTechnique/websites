FROM alpine:latest as build
RUN mkdir bloggo_not_doggo
COPY blog bloggo_not_doggo/blog

# get the hugo tooling into the container
COPY hugo_tools/hugo bloggo_not_doggo/hugo
WORKDIR bloggo_not_doggo/blog
RUN ../hugo

FROM nginx:latest
COPY --from=build /bloggo_not_doggo/blog/public/* /usr/share/nginx/html/

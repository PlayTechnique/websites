FROM alpine:latest
RUN apk add git
COPY hugo_files/hugo /app/hugo

RUN git clone https://github.com/gwynforthewyn/bloggo_not_doggo
WORKDIR bloggo_not_doggo
# RUN /app/hugo

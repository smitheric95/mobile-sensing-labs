FROM node:alpine
ADD . /app
WORKDIR /app
RUN echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories
RUN apk update
RUN apk add docker
CMD ["npm", "start"]


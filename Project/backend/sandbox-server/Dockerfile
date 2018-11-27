FROM python:3.6-alpine
ADD requirements.txt /requirements.txt
RUN pip install -r /requirements.txt
RUN echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories
RUN apk update
RUN apk add docker
WORKDIR /app
CMD ["python", "main.py"]


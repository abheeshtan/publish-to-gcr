ARG FUNCTION_DIR="/function"

FROM python:3.8.13-alpine3.16 AS alpine-image
RUN apk add --no-cache libstdc++
COPY LICENCE LICENCE

FROM alpine-image AS build-image
ARG FUNCTION_DIR

RUN apk add --no-cache \
    build-base \
    libtool \
    autoconf \
    automake \
    libexecinfo-dev \
    make \
    cmake \
    libcurl

COPY requirements.txt /tmp

RUN pip3 install --no-cache-dir --target ${FUNCTION_DIR} -r /tmp/requirements.txt --use-deprecated=backtrack-on-build-failures \
    && rm -rf /var/cache/* /root/.cache/*

RUN pip3 install cleanpy
RUN cleanpy ${FUNCTION_DIR}

FROM alpine-image
ARG FUNCTION_DIR

COPY --from=build-image ${FUNCTION_DIR} /usr/local/lib/python3.8/site-packages/

COPY ./README.MD /README.MD


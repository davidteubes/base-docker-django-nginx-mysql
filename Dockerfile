FROM python:3.9-buster
LABEL maintainer="dteubes@cgn.co.za"

ENV DJANGO_APP_ROOT /app
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

## these are default and should be passed & overwtiten during build
## (see note below, above "RUN useradd ...")
## eg.
## docker build -f Dockerfile \
## --build-arg USER=$(id -u -n) \
## --build-arg UID=$(id -u) \
## --build-arg GID=$(id -g) .
ARG USER=user
ARG UID=1000
ARG GID=1000
# ARG PW=docker

## current build ARGs are echoed (so you can see them)
RUN echo "UID=${UID},GID=${GID},USER=${USER}"

## this will set permissions so we dont have to chown files & folders every time
RUN groupadd -f --gid ${GID} ${USER} && \
    useradd -m -s /bin/bash -u ${UID} -g ${GID} ${USER}

## add so make it more secure
# RUN useradd -m -s /bin/bash -u ${UID} -g ${GID} ${USER}
# RUN useradd -m -s /bin/bash ${USER}

COPY requirements.txt requirements.txt

## copy & set permissions for wait-for-it.sh (waits for DB to be ready)
COPY wait-for-it.sh wait-for-it.sh
RUN chmod +x wait-for-it.sh

## create dirs for app
RUN mkdir -p ${DJANGO_APP_ROOT}
RUN mkdir -p ${DJANGO_APP_ROOT}/static
RUN mkdir -p ${DJANGO_APP_ROOT}/media


## install python pip requirements.txt
RUN pip install -U pip && \
        pip install -r requirements.txt

## set working dir
WORKDIR ${DJANGO_APP_ROOT}

## copy project into /home/user/app
COPY --chown=${UID}:${GID} ./app .

## set folders owner
# RUN chown ${UID}:${GID} ./static
# RUN chown ${UID}:${GID} ./media

## change to "user"
USER ${USER}
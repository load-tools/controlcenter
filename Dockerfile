FROM ubuntu:xenial
MAINTAINER Arseniy Fomchenko <fomars@yandex-team.ru>

RUN apt-get update -q && \
    apt-get install -yq \
        python-pip \
        vim \
        git \
        atop \
        telnet \
        expect

RUN mkdir -p /controlcenter
WORKDIR /controlcenter
ENV HOME /controlcenter

ARG TANK_BRANCH=release

RUN pip install --upgrade setuptools && \
    pip install --upgrade pip && \
    #https://github.com/pypa/pip/issues/5221
    hash -r pip && \
    pip install uwsgi && \
    pip install git+https://github.com/yandex/yandex-tank.git@${TANK_BRANCH}#egg=yandextank && \
    pip install -i https://pypi.yandex-team.ru/simple/ yasmapi

RUN git clone https://github.yandex-team.ru/load/yandex-tank-internal-pkg.git && \
    mkdir -p /etc/yandex-tank && \
    cp yandex-tank-internal-pkg/etc/yandex-tank/50-lunapark.yaml /etc/yandex-tank/50-lunapark.yaml

ARG APP_SETTINGS=app_settings.ini
ENV APPLICATION_SETTINGS $APP_SETTINGS

COPY api.py api.yaml server.py uwsgi.ini requirements.txt $APP_SETTINGS /controlcenter/
RUN pip install -r requirements.txt

COPY docker_entrypoint.sh /usr/local/bin/
RUN chmod 777 -R /usr/local/bin/docker_entrypoint.sh

ENTRYPOINT ["docker_entrypoint.sh"]
EXPOSE 80
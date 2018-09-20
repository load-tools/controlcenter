FROM ubuntu:xenial
MAINTAINER Arseniy Fomchenko <fomars@yandex-team.ru>

ARG TANK_BRANCH=release
ARG APP_SETTINGS=app_settings.ini
ARG YASM_PLUGIN="https://api.github.yandex-team.ru/repos/load/yasm-plugin/tarball/master"
ARG PYPI="https://pypi.yandex-team.ru/simple/"

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

RUN pip install --upgrade setuptools && \
    pip install --upgrade pip && \
    #https://github.com/pypa/pip/issues/5221
    hash -r pip && \
    pip install uwsgi && \
    pip install git+https://github.com/yandex/yandex-tank.git@${TANK_BRANCH}#egg=yandextank && \
    pip install -i ${PYPI} ${YASM_PLUGIN} && \

RUN git clone https://github.yandex-team.ru/load/yandex-tank-internal-pkg.git && \
    mkdir -p /etc/yandex-tank && \
    cp yandex-tank-internal-pkg/etc/yandex-tank/50-lunapark.yaml /etc/yandex-tank/50-lunapark.yaml

ENV APPLICATION_SETTINGS $APP_SETTINGS

COPY api.py api.yaml server.py uwsgi.ini requirements.txt $APP_SETTINGS /controlcenter/
RUN pip install -r requirements.txt

COPY docker_entrypoint.sh /usr/local/bin/
RUN chmod 777 -R /usr/local/bin/docker_entrypoint.sh

ENTRYPOINT ["docker_entrypoint.sh"]
EXPOSE 80
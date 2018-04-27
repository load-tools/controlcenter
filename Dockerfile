FROM ubuntu:16.04

RUN apt-get update -q && \
    apt-get install -yq \
        python-pip \
        vim \
        git \
        atop \
        telnet

RUN mkdir -p /controlcenter
WORKDIR /controlcenter
ENV HOME /controlcenter
ADD api.py api.yaml server.py uwsgi.ini requirements.txt /controlcenter/

RUN pip install --upgrade setuptools && \
    pip install --upgrade pip && \
    #https://github.com/pypa/pip/issues/5221
    hash -r pip && \
    pip install uwsgi && \
    pip install git+https://github.com/yandex/yandex-tank.git@release#egg=yandextank && \
    pip install -r requirements.txt

RUN git clone https://github.yandex-team.ru/load/yandex-tank-internal-pkg.git
RUN mkdir -p /etc/yandex-tank
RUN cp yandex-tank-internal-pkg/etc/yandex-tank/50-lunapark.yaml /etc/yandex-tank/50-lunapark.yaml
EXPOSE 80
CMD uwsgi --ini uwsgi.ini
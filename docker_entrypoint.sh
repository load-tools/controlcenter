#!/usr/bin/env bash
set -e
if [ -z "$APPLICATION_SETTINGS" ];
    then echo "Environment variable APPLICATION_SETTINGS should be set. Exiting.";
    exit 1;
fi
exec unbuffer uwsgi --ini uwsgi.ini "$@" |& tee uwsgi.log
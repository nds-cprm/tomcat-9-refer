#!/bin/bash
set -eux
# agsb@2020, let this container stay alive
# from https://github.com/docker/compose/issues/1926,  qoomon commented on 25 Jun 2019 •

# Ah, ha, ha, ha, stayin' alive...
while :; do :; done & kill -STOP $! && wait $!

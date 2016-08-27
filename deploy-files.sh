#!/bin/bash

HOST=$1
VERS=$2

function cmd() { echo "$@" ; "$@" ; }

cmd rsync -rplcv "install/" "$HOST:/"

true

#!/usr/bin/env bash

image="a.b"

if [[ "${image}" != *"/"* ]] || [[ "${image}" == *"."* ]]; then
    echo "not docker.io"
else
    echo "docker.io"
fi


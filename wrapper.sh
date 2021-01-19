#!/bin/bash

if [ -z "$REQUIREMENTS_PATH" ]; then
    REQUIREMENTS_PATH=features/steps/requirements.txt
fi

if [ -f "$REQUIREMENTS_PATH" ]; then
    pip3 install --no-cache-dir -r $REQUIREMENTS_PATH
fi

exec behave "$@"
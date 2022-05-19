#!/bin/bash

if [ -n "$ADDITIONAL_PATH" ]; then
    echo "Adding to PATH: $ADDITIONAL_PATH"
    export PATH="$ADDITIONAL_PATH:$PATH"
fi

/bin/bash
#!/bin/bash
set +x

target=$1
retries=$2
delay=$3

echo "Running highstate on minion $target with retries: $retries | delay: $delay"

count=1
while true; do
    echo "Highstate attempt #$count .."
    outcome="true"
    result=$(sudo salt "$target" state.highstate --out json | jq -r '.[] | .[] | .result')
    echo -e "result:\n$result"
    if [[ $result ]]; then
        for line in $result; do
            if [[ "$line" != "true" ]]; then
                outcome="false"
            fi
        done
    else
        outcome="false"
    fi
    if [[ "$outcome" == "true" ]]; then
        exit 0
    else
        if ((count == retries)); then
            exit 1
        fi
        sleep $delay
        ((count ++))
    fi
done
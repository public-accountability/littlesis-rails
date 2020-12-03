#!/bin/sh

for i in $(seq 1 10);do
    if nc -z 127.0.0.1 3306
    then
        echo 'Success' && exit 0
    else
        sleep 1
    fi
done

echo "Failed waiting for MySQL" && exit 1

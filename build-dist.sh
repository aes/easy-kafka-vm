#!/bin/bash

set -euo pipefail

mkdir -p files packages ansible_collections/confluent/

while read -r url pkg size hash ; do
    url="${url%%"'"}"
    url="${url##"'"}"
    printf "%s\n" $pkg
    printf "  %s\n" "$url"
    printf "  %s\n" "$size"
    printf "  %s\n" "$hash"

    wget \
        --continue \
        --output-document="packages/$pkg" \
        "$url"

done < packages.tsv

VERSION=$(cat version.txt)

echo "VERSION=$VERSION" >> "${GITHUB_ENV:-github.env}"

(
    cd ansible_collections/confluent/
    git \
        clone \
        --branch 7.9.1-post \
        https://github.com/confluentinc/cp-ansible.git \
        || true
)

for url in \
    https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.12.0/jmx_prometheus_javaagent-0.12.0.jar \
    http://packages.confluent.io/archive/7.9/confluent-community-7.9.1.tar.gz \
    https://repo1.maven.org/maven2/org/jolokia/jolokia-jvm/1.6.2/jolokia-jvm-1.6.2.jar
do
    echo wget \
        --continue \
        --output-document="files/${url##*/}" \
        "$url"
    wget \
        --continue \
        --output-document="files/${url##*/}" \
        "$url"
done

(cd files && sha256sum -c all.sha256)

tar cvz \
    -f "/tmp/easy-kafka-vm_${VERSION}.tar.gz" \
    --exclude='.*' \
    -C .. \
    "$(basename "$PWD")"

#!/bin/bash

: "${N:=1}"

for ((i=1 ; i <= N ; i++)); do
    virsh destroy  knas$i || true
    virsh undefine knas$i || true
done

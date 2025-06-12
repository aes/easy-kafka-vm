#!/bin/bash

set -euo pipefail

: "${NAME:=knas}"
: "${LIBVIRT_IMAGE_DIR:=/var/lib/libvirt/images}"
# : "${IMAGE:=${LIBVIRT_IMAGE_DIR}/debian-10-genericcloud-amd64.qcow2}"
: "${IMAGE:=${LIBVIRT_IMAGE_DIR}/debian-12-genericcloud-amd64.qcow2}"
# : "${IMAGE:=${LIBVIRT_IMAGE_DIR}/oracular-server-cloudimg-amd64.img}"

: "${N:=1}"

printf "\e[31m%s: %s\e[0m\n" N "$N"
printf "\e[31m%s: %s\e[0m\n" NAME "$NAME"
printf "\e[31m%s: %s\e[0m\n" LIBVIRT_IMAGE_DIR "$LIBVIRT_IMAGE_DIR"
printf "\e[31m%s: %s\e[0m\n" IMAGE "$IMAGE"


for ((i=1 ; i <= N ; i++)); do

    INSTANCE="${NAME}${i}"
    DEST="${LIBVIRT_IMAGE_DIR}/${INSTANCE}.qcow2"
    CIDATA="${LIBVIRT_IMAGE_DIR}/${INSTANCE}-ci.iso"
    MAC="$(printf "52:54:00:00:7a:%02x" "$((40 + i))")"

    printf "\e[31m%s: %s\e[0m\n" INSTANCE "$INSTANCE"
    printf "\e[31m%s: %s\e[0m\n" MAC "$MAC"

    virsh destroy "${INSTANCE}" || true
    virsh undefine --domain "${INSTANCE}" || true

    qemu-img            \
        create         \
        -b "${IMAGE}"  \
        -f qcow2       \
        -F qcow2       \
        "${DEST}"      \
        10G

    cat > meta-data <<EOF
instance-id: ${INSTANCE}
local-hostname: ${INSTANCE}
EOF

    genisoimage               \
        -output "${CIDATA}"   \
        -input-charset utf-8  \
        -volid cidata         \
        -rational-rock        \
        -rock                 \
        -joliet               \
        user-data             \
        meta-data

    rm meta-data

    virt-install                                                    \
        --name="${INSTANCE}"                                        \
        --ram=3072                                                  \
        --vcpus=1                                                   \
        --sysinfo entry0.name=host,entry0="${INSTANCE}"             \
        --os-variant=linux2024                                      \
        --network=bridge=virbr0,model=virtio,mac="$MAC"             \
        --import                                                    \
        --disk path="${DEST}",format=qcow2                          \
        --disk path="${CIDATA}",format=iso                          \
        --graphics=none                                             \
        --noautoconsole
done

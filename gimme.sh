#!/bin/bash

set -euo pipefail

START="$PWD"

url_decode() {
    # Replace '+' with space, then decode %XX
    decoded=$(echo "$1" | sed 's/+/ /g; s/%/\\x/g')
    printf '%b\n' "$decoded"
}

ensure_files() {
    while read -r want url_path filename; do
        path="$(url_decode "$url_path")"
        package="${filename%%_*}"

        if [ -f "$filename" ]; then
            have="$(sha512sum "$filename" | cut -d' ' -f1)"

            if [ "$have" = "$want" ]; then
                printf "%s ok\n" "$package"
            else
                printf "%s mismatch\n" "$package"
                printf "  have %s\n" "$have"
                printf "  want %s\n" "$want"
wget \
    --continue \
                    --output-document "$filename" \
                    "$BASE"/"$url_path"
            fi
        else
            printf "%s absent\n" "$package"
            wget \
                --continue \
                --output-document "$filename" \
                "$BASE"/"$url_path"
        fi
    done
}

ensure_jre_package_files() {
BASE=http://ftp.se.debian.org/debian/pool/main/
    cd "$START"
    cd ansible_collections/anzr/kafka/roles/jre/files/ || exit 1

    sha512sum -c all.sha512sum && printf "all ok\n" && return 0

printf "%s" "\
47add705a267b4f18e1c0b69de4225ab5b2de581aa1737cb6af820e7ee120f25be4ed3ad15349e5364d14774eeb59388c4449c93158e8bf09a56809b51158746  a/alsa-lib/libasound2_1.2.8-1%2bb1_amd64.deb     libasound2_1.2.8-1+b1_amd64.deb
3dff534934e70f7f45494fb419dde2909965ca253e02739e7ccdd2d53bca39a589e8f552c26a61bf8d761b40e4d28cbe8ed88ecbcb6422d0502b6c3445061944  a/alsa-lib/libasound2-data_1.2.8-1_all.deb       libasound2-data_1.2.8-1_all.deb
928929d2e4571de16c0fde7d19b5b70db6e522dc0fbf199c7577b17f333480cedc12ddd8345588ef3089e9abfc80c3d92a80b9be10c7c18750bb769cfed692c5  a/alsa-topology-conf/alsa-topology-conf_1.2.5.1-2_all.deb        alsa-topology-conf_1.2.5.1-2_all.deb
68f5da9c789fde13162113ae3e754024685ca82dcd024f19b6d4a2202f45d8acf3939bec7072986a2ffe489b1e97b004dee9e8dae13db1add3eef591a370f282  a/alsa-ucm-conf/alsa-ucm-conf_1.2.8-1_all.deb    alsa-ucm-conf_1.2.8-1_all.deb
b2a146c771aa9b40a8b3877528c7692be858dd9fa03de1f8982a162b53d8d252a93b5b171fe3fb7ec8c421e5af407025d30a2842d85c59f4f4a91f0407f09cb4  a/avahi/libavahi-client3_0.8-10%2bdeb12u1_amd64.deb      libavahi-client3_0.8-10+deb12u1_amd64.deb
5f8a85744b33075379da8deb7409ed02f7d8ddf0af8760831e5219c6b82567f2ee5d759e3fee82bff9dcc2d9f241bb2df0c320115df698b26da88bc61970584c  a/avahi/libavahi-common-data_0.8-10%2bdeb12u1_amd64.deb  libavahi-common-data_0.8-10+deb12u1_amd64.deb
d4a5ce479cad2a7846201188c8be5d94061ce90eb93cd78efcae97e59c8fa1a5cfc8230979c793753bfa87d46261cf4d019bafa9a399aac9b2ae9bfe2cfbda48  a/avahi/libavahi-common3_0.8-10%2bdeb12u1_amd64.deb      libavahi-common3_0.8-10+deb12u1_amd64.deb
aae065c116715aa82f8bfa7aa7386d6dc4a04aafc17710e3bce60725ac7f0b9d73bf37b63d10e936d11d633813328b7ac09fd70cbb7e271539047f07592779ad  c/ca-certificates-java/ca-certificates-java_20230710%7edeb12u1_all.deb   ca-certificates-java_20230710~deb12u1_all.deb
491b99fa62425601d3055232adb84202003af681490e1c01cb23f51cf1d1856a8914e85bdfcb3708c1ed339914b53f1926b8973d050d348d3597183e5cb1423d  c/cups/libcups2_2.4.2-3%2bdeb12u8_amd64.deb      libcups2_2.4.2-3+deb12u8_amd64.deb
f466012abaf2bf1d98f5d523169275cacec2bc893c48b488ae1e5dfdc1c81fa1a00147cd859ee9946a311a7fea8ed061f5ee47270a336ef93377a12f7b156697  f/fontconfig/fontconfig-config_2.14.1-4_amd64.deb        fontconfig-config_2.14.1-4_amd64.deb
2a9c31c7f3e65c41714a61fad170aeacf2b16126bff2036fcf5fb2ea0b5db53313a321bb68233bd4ae1e4ef51e0edde47d06334e54265065d265d5c460904c7e  f/fontconfig/libfontconfig1_2.14.1-4_amd64.deb   libfontconfig1_2.14.1-4_amd64.deb
c74012a410d1f9c99e36cc20c21580f590fb62c76af6fa7e6a3597833ef7c6406fcf81809a5a217b3477380498e4d259f5d08052628643e843853579a0e6e9df  f/fonts-dejavu/fonts-dejavu-core_2.37-6_all.deb  fonts-dejavu-core_2.37-6_all.deb
f2789e6ae3df4e1ab50316d8d790fcf6beceb496a999b991b44e357d00cfc351a410b20d38a6aa7d53845cebbd94c2de6f45080277079c94ce6a9cf6229a0431  g/graphite2/libgraphite2-3_1.3.14-1_amd64.deb    libgraphite2-3_1.3.14-1_amd64.deb
a183f931e6d1c62e939c7115b366b725aa99160493956eee255cb5b4567e6fbc8c90b28236edff86076b419d238568d080fe5905b27e40d350561bfc614d561b  h/harfbuzz/libharfbuzz0b_6.0.0%2bdfsg-3_amd64.deb        libharfbuzz0b_6.0.0+dfsg-3_amd64.deb
e3f869d704ed8db9ed630acaa7a09873e5eec55c91a9137a5fd9ff3a5a7e32713884ba467aef781121e86047599584213df3e70d5027a7c2c7897007516e4ee6  j/java-common/default-jre-headless_1.17-74_amd64.deb     default-jre-headless_2%3a1.17-74_amd64.deb
e69466e65c3cf3793413b679d1fdaa2cc304005694cee35c5ff69a016ee57365620d8469bb3af9d64ecc940a0766254a22ae9a728d9defdb7c40fe3ff592692e  j/java-common/java-common_0.74_all.deb   java-common_0.74_all.deb
4cac8ae7077e8684cbbce142b706c278367dadf74a5dd371f6d9a9b77c967f42d832797a0a37fd659933350f1bbd0d92aa7905d8b559c0b6d1e8206d7753cac5  l/lcms2/liblcms2-2_2.14-2_amd64.deb      liblcms2-2_2.14-2_amd64.deb
67ef9c7a83dd84eea853c6e67b7611051c6ba5d7eebff63001c882264fbc7b5d9ba22ed72e8a9e21715b1ea7f91e9e8a97c7c3766b96544a1458d34d21e382a1  libj/libjpeg-turbo/libjpeg62-turbo_2.1.5-2_amd64.deb     libjpeg62-turbo_1%3a2.1.5-2_amd64.deb
1fed7fc825bfc4f0dbbdb51000afb2548972c56d25619c55154233c2176f43ce6a50057cc943c974f1bcfa27061d0855bdec206d7d80c709cb2c70c2845520ff  n/nspr/libnspr4_4.35-1_amd64.deb libnspr4_2%3a4.35-1_amd64.deb
d9926b784eff69b41b2c6d6ab0b0909a5d1e0934ed5ebd213fd346c530fb3efb9ce7b9952efaf67ba2539c19ae803c44ad3db0b6d4e14ff3cdfe76a27da66f7d  n/nss/libnss3_3.87.1-1%2bdeb12u1_amd64.deb       libnss3_2%3a3.87.1-1+deb12u1_amd64.deb
c7e63074d686729936950afc3bc4780fe69a7602040894a340159e14c9627fa7e3f342466cb4134525a5cf41e753a910da3e102540b2b4f31ce518c256748c7c  o/openjdk-17/openjdk-17-jre-headless_17.0.15%2b6-1%7edeb12u1_amd64.deb   openjdk-17-jre-headless_17.0.15+6-1~deb12u1_amd64.deb
49615fcdbd496e3fe5ed607ece05973e4068b3196e35f48c3bc5e78445b6d1d21c16a7da4e2fe9efef19615d7d0c333715fd09e84ca7eb03a05fd0bedde26152  p/pcsc-lite/libpcsclite1_1.9.9-2_amd64.deb       libpcsclite1_1.9.9-2_amd64.deb
" | ensure_files

    sha512sum -c all.sha512sum
}

ensure_kafka_archive() {
    BASE=https://dlcdn.apache.org/kafka/4.0.0/
    cd "$START"
    cd ansible_collections/anzr/kafka/roles/kafka/files/ || exit 1

    sha512sum -c all.sha512sum && printf "all ok\n" && exit 0

    printf "%s" "\
00722ab0a6b954e0006994b8d589dcd8f26e1827c47f70b6e820fb45aa35945c19163b0f188caf0caf976c11f7ab005fd368c54e5851e899d2de687a804a5eb9  kafka_2.13-4.0.0.tgz kafka_2.13-4.0.0.tgz
" | ensure_files

sha512sum -c all.sha512sum
}

ensure_jre_package_files && ensure_kafka_archive

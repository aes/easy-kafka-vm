
: "${NAME:=kitten}"
: "${N:=3}"

N="$N" NAME="$NAME" sudo -E bash -x ./bake.sh

for ((i=0 ; i<N ; i++)); do
    INSTANCE="${NAME}${i}"
    IP="192.168.122.$((32 + i))"
    printf "IP: %s\n" "$IP"

    for ((j=0; j<20; j++)); do
        if ssh -i ~aes/.ssh/aes@rune -o StrictHostKeyChecking=no -o "UserKnownHostsFile=/dev/null" "franz@$IP" true 2>/dev/null ; then
            ok=true
            printf "\n"
            break
        else
            printf "."
            sleep 1
        fi
    done
done
printf "\n"

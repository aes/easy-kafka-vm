
: "${NAME:=kitten}"
: "${N:=3}"

N="$N" NAME="$NAME" sudo -E bash -x ./bake.sh

for ((i=0 ; i<N ; i++)); do
    INSTANCE="${NAME}${i}"

    for ((j=0; j<20; j++)); do
        if ssh -i ~aes/.ssh/aes@rune -o StrictHostKeyChecking=no -o "UserKnownHostsFile=/dev/null" "franz@$INSTANCE" true ; then
            ok=true
            break
        else
            printf "."
            sleep 1
        fi
    done
done
printf "\n"

ansible-playbook -v -i hosts.yml kafka.yml

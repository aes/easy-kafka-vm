# Setup

    # to retrieve packages
    bash ./gimme.sh

    # to set up VM:s
    sudo bash ./setup.sh

    rsync -a ./ franz@192.168.122.41:fnord

    # to run Ansible
    ansible-playbook \
      -i hosts.yml \
      --become-password-file=.become-pass \
      confluent.platform.validate_hosts

# On the node(s)

## Preliminaries

    echo 'PATH=$PATH:/opt/confluent/confluent-7.9.1/bin/' >> .profile
    echo 'unset $(env | grep ^LC | cut -d= -f1)' >> .profile
    dpkg --get-selections > selections-before-install.txt
    sudo apt install ansible rsync

## Make it possible to ssh to self

    ssh-keygen
    cat .ssh/id_rsa.pub >> .ssh/authorized_keys

## Fix path to packages

    sed "s,pwd: .*,pwd: $PWD," -i hosts.yml

    # ...

    dpkg --get-selections > selections-after-install-headless.txt

# Update packages.tsv

    comm -3 \
        selections-after-install-headless.txt \
        selections-before-install.txt \
      | sed 's:\t\t*install::' \
      > needed_packages.txt

    apt download --print-uris $(cat needed_packages.txt) > packages.tsv

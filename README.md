# Setup

    # to retrieve packages
    bash ./gimme.sh

    # to set up VM:s
    bash ./setup.sh

    # to run Ansible
    ansible-playbook -v -i hosts.yml kafka.yml

# On the node(s)

    # start controller
    sudo /opt/kafka/bin/kafka-server-start.sh /etc/kafka/controller-server.properties > controller.out 2> controller.err &

    # start broker
    sudo /opt/kafka/bin/kafka-server-start.sh /etc/kafka/broker-server.properties > broker.out 2> broker.err &

    # follow logs
    tail -f *.{out,err}

    # shut down kafka
    sudo pkill -f kafka-server-start

    # ...
    PATH="$PATH:/opt/kafka/bin/"
    BOOT="--bootstrap-server=$HOSTNAME:9092"

    kafka-topics.sh --create "$BOOT" --topic test --partitions 3 --replication-factor 3
    kafka-topics.sh --describe "$BOOT" --topic test


    kafka-console-producer.sh "$BOOT" --topic test

    kafka-console-consumer.sh "$BOOT" --topic test --from-beginning

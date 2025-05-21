for i in 0 1 2 ; do virsh destroy kitten$i || true ; virsh undefine kitten$i || true ; done

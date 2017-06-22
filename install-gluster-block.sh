sshkey="~/.vagrant.d/insecure_private_key"
script="install-gluster-block-internal.sh"
user="root"

for host in 192.168.55.1{4,5,6} ; do
	echo $host:
	scp -i $sshkey $script $user@$host:
	ssh -i $sshkey $user@$host -C sh ./$script
done


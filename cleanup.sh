sshcmd="ssh -i ~/.vagrant.d/insecure_private_key -l root"

echo
echo stop and delete gluster volumes
echo

for host in 192.168.55.1{4,5,6} ; do
	_sshcmd="$sshcmd $host -C"
	echo $host:
	volumes=$($_sshcmd gluster volume list)
	echo volumes: $volumes
	for volume in $volumes ; do
		echo "stopping volume $volume"
		$_sshcmd "echo 'y' | gluster volume stop $volume"
		echo "deleting volume $volume"
		$_sshcmd "echo 'y' | gluster volume delete $volume"
	done
done

echo
echo umount bricks
echo

for host in 192.168.55.1{4,5,6} ; do
	_sshcmd="$sshcmd $host -C"
	echo $host:
	mtpts=$(eval "$_sshcmd mount" | grep vg_ | awk '{ print $3 }')
	echo mtpts: $mtpts
	for mtpt in $mtpts ; do
		cmd="umount $mtpt"
		echo cmd: \"$cmd\"
		$_sshcmd $cmd
	done
done

echo
echo removing VGs
echo

for host in 192.168.55.1{4,5,6} ; do
	_sshcmd="$sshcmd $host -C"
	echo $host:
	vgs=$($_sshcmd "vgs --no-headings" |  awk '{ print $1 }')
	echo vgs: $vgs
	for vg in $vgs ; do
		echo deleting vg $vg
		$_sshcmd vgremove $vg --force
	done
done

echo
echo removing PVs
echo

for host in 192.168.55.1{4,5,6} ; do
	_sshcmd="$sshcmd $host -C"
	echo $host:
	pvs=$($_sshcmd "pvs --no-headings" |  awk '{ print $1 }')
	echo pvs: $pvs
	for pv in $pvs ; do
		echo deleting pv $pv...
		$_sshcmd pvremove $pv --force
	done
done


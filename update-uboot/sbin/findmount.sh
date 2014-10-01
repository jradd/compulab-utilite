#!/bin/bash

set -x

getMount(){
	loc=$1
	#If it's a device node, let's look it up
	if [[ $loc =~ ^/dev ]]; then
		#If it's a device node, let's look it up
		if [[ -h $loc ]]; then
			#It's a symlink, resolve it back 
			loc=$(readlink -f $loc)
		fi
		#Check if it's already mounted
		#use df rather than /proc/mounts to make sure we have the real blockdev
		mounted=$(df -l --output=source,target | grep $loc)
		if [ -n "$mounted" ]; then
			mounted=$(echo $mounted | awk '{ print $2 }')
		else
			#Might be in fstab
			mount $loc
			if [ $? -eq 0 ]; then
				mounted=$(df -l --output=source,target | grep $loc | awk '{ print $2 }')
			else
				#OK, so we invent a mountpoint
				mounted=$(mktemp -d)
				mount $loc $mounted || { echo "Couldn't mount blockdev $loc!"; exit 1 ; }
			fi
		fi
	elif [[ ! -d $loc ]]; then
		#not a device and not a directory
		echo "Directory $loc doesn't exist"
	        exit 1	
	elif [[ -z $(grep " $loc " /proc/mounts) ]]; then
		#an unmounted dir should be in fstab
		mount $loc || { echo "Couldn't mount directory ${loc}!" ; exit 1 ; }
		mounted=$loc
	else
		#it's already mounted
		mounted=$loc
	fi

	echo "$mounted"
	return 0
}


getMount $1


#!/bin/bash

# Go to git repo root
cd `dirname $0`
cd ..

function insudo {
    user=`whoami`
    if [ "$user" = "root" ] ; then
	"$@"
	return
    fi
    if [ ! -x /usr/bin/sudo ] ; then
	echo "Sudo not installed and installation not possible as regular user"
	exit 1
    fi
    /usr/bin/sudo "$@"
}

set -ex
for step in $* ; do
    case $step in
	update)
	    insudo yum install -y deltarpm
	    # Update on filesystem package fails on CircleCI containers and on some else as well
	    # Enable workaround
	    insudo sed -i -e '$a%_netsharedpath /sys:/proc' /etc/rpm/macros.dist 
	    insudo yum update -y
	    ;;
	prep)
	    for pck in \
    		    yum-utils \
		    git ; do
		 insudo yum install -y "$pck" || insudo yum reinstall -y "$pck"
	    done
	    # This will speedup future steps and there seems to be
	    # wrong URLs in these in some cases
	    insudo rm -f /etc/yum.repos.d/CentOS-Vault.repo /etc/yum.repos.d/CentOS-Sources.repo
	    ;;
	cache)
	    insudo yum clean all
	    insudo rm -rf /var/cache/yum
	    insudo yum makecache
	    ;;
	deps)
	    insudo yum-builddep -y *.spec
	    ;;
	rpm)
	    make rpm
	    mkdir -p $HOME/dist
	    for d in /root/rpmbuild $HOME/rpmbuild ; do
	    	test ! -d "$d" || find "$d" -name \*.rpm -exec mv -v {} $HOME/dist/ \; 
	    done
	    set +x
	    echo "Distribution files are in $HOME/dist:"
	    ls -l $HOME/dist
	    ;;
	*)
	    echo "Unknown build step $step"
	    ;;
    esac
done

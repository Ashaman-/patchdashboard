#!/bin/bash
# generated installation key and server URI from install
auth_key="__SERVER_AUTHKEY_SET_ME__"
server_uri="__SERVER_URI_SET_ME__"
submit_packages_uri="${server_uri}client/send_packages.php"

#Force a run of check-in.sh if .patchrc is missing.
if [[ ! -f "/opt/patch_manager/.patchrc" ]]; then
	echo "Please run /opt/patch_manager/check-in.sh as root (sudo) before trying to run this manually"
	exit 0
fi
# load the file
. /opt/patch_manager/.patchrc
if [[ -f /etc/lsb-release && -f /etc/debian_version ]]; then
        os=$(lsb_release -s -d|head -1|awk {'print $1'})
elif [[ -f /etc/debian_version ]]; then
        os="Debian"
elif [[ -f /etc/redhat-release ]]; then
        os=$(cat /etc/redhat-release|head -1|awk {'print $1'})
	if [[ "$os" = "Red" && $(grep -i enterprise /etc/redhat-release) != "" ]]; then
		os="RHEL"
	elif [[ "$os" = "Red" ]]; then
		os="RHEL"
	fi
else
        os=$(uname -s -r|head -1|awk {'print $1'})
fi
if [ "$os" = "CentOS" ] || [ "$os" = "Fedora" ] || [ "$os" = "RHEL" ]; then
        data=$(rpm -qa --qf '%{NAME}:::%{VERSION}\n')
elif [ "$os" = "Ubuntu" ] || [ "$os" = "Debian" ]; then
	data=$(dpkg -l|grep "ii"|awk '{print $2":::"$3}')
elif [ "$os" = "Linux" ]; then
	echo "unspecified $os not supported"
	exit 0
fi
if [ -z "$data" ]; then
	exit 0
else
	curl -k -H "X-CLIENT-KEY: $client_key" $submit_packages_uri -d "$data" > /dev/null 2>&1
fi

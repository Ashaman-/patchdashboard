#!/bin/bash
auth_key="__SERVER_AUTHKEY_SET_ME__"
server_uri="__SERVER_URI_SET_ME__"
get_cmd_uri="${server_uri}client/get_commands.php"
#Force a run of check-in.sh if .patchrc is missing.
if [[ ! -f "/opt/patch_manager/.patchrc" ]]; then
        echo "Please run /opt/patch_manager/check-in.sh as root (sudo) before trying to run this manually"
        exit 0
fi
. /opt/patch_manager/.patchrc
rm -rf /tmp/cmds_$client_key > /dev/null 2>&1
curl -s -H "X-CLIENT-KEY: $client_key" $get_cmd_uri > /tmp/cmds_$client_key
cmds_line_count=$(cat /tmp/cmds_$client_key|wc -l)
if [ "$cmds_line_count" -gt "0" ]; then
        . /tmp/cmds_$client_key
        key_sum=$(echo $key_to_check|sha256sum)
        auth_sum=$(echo $auth_key|sha256sum)
        if [ "$key_sum" == "$auth_sum" ]; then
                echo $cmd_to_run|bash
        fi
fi
rm -rf /tmp/cmds_$client_key
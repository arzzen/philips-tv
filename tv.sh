#!/bin/bash

set -o nounset
set -o errexit

ip="${_TV_IP:-}"
if [[ $ip = "" ]]; then
    echo "Please set up IP for your TV."
    echo ""
    echo "Usage:"
    echo "export _TV_IP=\"192.169.0.10\" && ./tv.sh <optional-command-to-execute-directly>";
    exit 1;
fi

IP="https://$ip:1926/6"

function show_menu() {
    NORMAL=`echo "\033[m"`
    MENU=`echo "\033[36m"`
    NUMBER=`echo "\033[33m"`
    FGRED=`echo "\033[41m"`
    RED_TEXT=`echo "\033[31m"`
    ENTER_LINE=`echo "\033[33m"`

    echo -e ""
    echo -e "${RED_TEXT} Channels: ${NORMAL}"
    echo -e "${MENU} ${NUMBER} 1)${MENU} Returns all installed channels ${NORMAL}"
    echo -e "${MENU} ${NUMBER} 2)${MENU} Returns the current channel ${NORMAL}"
    echo -e "${MENU} ${NUMBER} 3)${MENU} Changes the current channel step up ${NORMAL}"
    echo -e "${MENU} ${NUMBER} 4)${MENU} Changes the current channel step down ${NORMAL}"

    echo -e "${RED_TEXT} Audio: ${NORMAL}"
    echo -e "${MENU} ${NUMBER} 5)${MENU} Returns the current volume ${NORMAL}"
    echo -e "${MENU} ${NUMBER} 6)${MENU} Changes the current volume step up ${NORMAL}"
    echo -e "${MENU} ${NUMBER} 7)${MENU} Changes the current volume step down ${NORMAL}"

    echo -e "${RED_TEXT} Ambilight: ${NORMAL}"
    echo -e "${MENU} ${NUMBER} 8)${MENU} Returns the number of layers and the number of pixels on each side ${NORMAL}"
    echo -e "${MENU} ${NUMBER} 9)${MENU} Returns the ambilight mode ${NORMAL}"
    echo -e "${MENU} ${NUMBER} 10)${MENU} Returns the ambilight colours stored in the cache ${NORMAL}"

    echo -e "${RED_TEXT} System: ${NORMAL}"
    echo -e "${MENU} ${NUMBER} 11)${MENU} Returns all system settings ${NORMAL}"
    echo -e "${MENU} ${NUMBER} 12)${MENU} Stand by ${NORMAL}"
    echo -e "${MENU} ${NUMBER} 13)${MENU} Send GET command ${NORMAL}"
    echo -e "${MENU} ${NUMBER} 14)${MENU} Send POST command ${NORMAL}"

    echo -e ""
    echo -e "${ENTER_LINE}Please enter a menu option or ${RED_TEXT}press enter to exit. ${NORMAL}"
    read opt
}

function option_picked() {
    COLOR='\033[01;31m'
    RESET='\033[00;00m'
    MESSAGE=${@:-"${RESET}Error: No message passed"}
    echo -e "${COLOR}${MESSAGE}${RESET}"
    echo ""
}

function randomString() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
}

function signature() {
    echo -n "$1" | openssl dgst -sha1 -hmac "$2" -binary | base64
}

function deviceSpecJson() {
    echo "{ \"app_id\": \"gapp.id\", \"id\":\"$1\", \"device_name\" : \"heliotrope\", \"device_os\" : \"Android\", \"app_name\" : \"ApplicationName\", \"type\" : \"native\" }"
}

function pair() {
    deviceId=$(randomString 16)
    device=$(deviceSpecJson $deviceId)
    data="{ \"device\": $device, \"scope\": [\"read\", \"write\", \"control\"] }"
    response=$(curl -s -k -X POST "$IP/pair/request" --data "$data")

    auth_key=$(echo $response | jq .auth_key | tr -d '"')
    timestamp=$(echo $response | jq .timestamp | tr -d '"')
    timeout=$(echo $response | jq .timeout | tr -d '"')

    echo "Please enter 4 digit PIN code from your TV:"
    read pin

    secret_key="ZmVay1EQVFOaZhwQ4Kv81ypLAZNczV9sG4KkseXWn1NEk6cXmPKO/MCa9sryslvLCFMnNe4Z4CPXzToowvhHvA=="
    auth_timestamp="$timestamp$pin"
    auth_key_s=$(echo $secret_key | base64 -d)
    signature=$(signature $auth_key_s $auth_timestamp)

    auth="{\"device\":{\"device_name\":\"heliotrope\",\"device_os\":\"Android\",\"app_name\":\"ApplicationName\",\"type\":\"native\",\"app_id\":\"app.id\",\"id\":\"$deviceId\"},\"auth\":{\"auth_AppId\":\"1\",\"pin\":$pin,\"auth_timestamp\":\"$auth_timestamp\",\"auth_signature\":\"$signature\"}}"
    response=$(curl -k -s --digest --user $deviceId:$auth_key -X POST "$IP/pair/grant" --data "$auth")

    echo "$deviceId:$auth_key" > .credentials.tv
}

function cmd() {
    if [ ! -f .credentials.tv ]
    then
        pair
    fi

    auth=$(cat .credentials.tv)
    command=$(curl -k -s --digest --user $auth -X GET "$IP/$1" )
    echo $command
}

function cmdPost() {
    if [ ! -f .credentials.tv ]
    then
        pair
    fi

    auth=$(cat .credentials.tv)
    command=$(curl -k -s --digest --user $auth -X POST "$IP/input/key" -d "{\"key\":\"$1\"}" )
    echo "{\"status\":\"OK\"}"
}

if [ $# -eq 1 ]
  then
     case $1 in
        "allChannels")
           cmd "channeldb/tv/channelLists/all"
           ;;
        "currentChannel")
           cmd "activities/tv"
           ;;
        "changeChannel")
           echo "@todo"
           #cmdPost "activities/tv"
           #config['body'] = {"channel":{"ccid": args.value },"channelList":{"id":"allcab","version":"9"}}"
           ;;
        "channelUp")
           cmdPost "ChannelStepUp"
           ;;
        "channelDown")
           cmdPost "ChannelStepDown"
           ;;
        "volume")
           cmd "audio/volume"
           ;;
        "volumeUp")
           cmdPost "VolumeUp"
           ;;
        "volumeDown")
           cmdPost "VolumeDown"
           ;;
        "ambilightConfig")
           cmd "ambilight/currentconfiguration"
           ;;
        "ambilightTopology")
           cmd "ambilight/topology"
           ;;
        "ambilightCache")
           cmd "ambilight/cached"
           ;;
        "systemInfo")
           cmd "system"
           ;;
        "standby")
           cmdPost "Standby"
           ;;
        "getCommand")
           command="${_TV_COMMAND:-}"
           while [ -z "$command" ]; do read -p "Which command? " command; done
           cmd "$command"
           ;;
        "postCommand")
           command="${_TV_COMMAND:-}"
           while [ -z "$command" ]; do read -p "Which command? " command; done
           cmdPost "$command"
           ;;
        *)
           echo "Invalid argument. Possible arguments: allChannels currentChannel channelUp channelDown volume volumeUp volumeDown ambilightConfig ambilightTopology ambilightCache systemInfo getCommand postCommand"
           exit 1
           ;;
     esac
     exit 0;
fi

if [ $# -gt 1 ]
    then
    echo "Usage: ./tv.sh <optional-command-to-execute-directly>";
    exit 1;
fi

clear
show_menu

while [ opt != '' ]
    do
    if [[ $opt = "" ]]; then
        exit;
    else
        clear
        case $opt in
        1)
           cmd "channeldb/tv/channelLists/all"
           show_menu
           ;;
        2)
           cmd "activities/tv"
           show_menu
           ;;
        3)
           cmdPost "ChannelStepUp"
           show_menu
           ;;
        4)
           cmdPost "ChannelStepDown"
           show_menu
           ;;
        5)
           cmd "audio/volume"
           show_menu
           ;;
        6)
           cmdPost "VolumeUp"
           show_menu
           ;;
        7)
           cmdPost "VolumeDown"
           show_menu
           ;;
        8)
           cmd "ambilight/currentconfiguration"
           show_menu
           ;;
        9)
           cmd "ambilight/topology"
           show_menu
           ;;
        10)
           cmd "ambilight/cached"
           show_menu
           ;;
        11)
           cmd "system"
           show_menu
           ;;
        12)
           cmdPost "Standby"
           show_menu
           ;;   
        13)
           command=''
           while [ -z "$command" ]; do read -p "Which command? " command; done
           cmd "$command"
           show_menu
           ;;
        14)
           command=''
           while [ -z "$command" ]; do read -p "Which command? " command; done
           cmdPost "$command"
           show_menu
           ;;
        q)
           exit
           ;;
        \n)
           exit
           ;;
        *)
           clear
           option_picked "Pick an option from the menu"
           show_menu
           ;;

    esac
fi
done

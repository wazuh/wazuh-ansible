#!/bin/sh

# Initialize variables
ip_address=$(ip route get 1.1.1.1 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
host=$(hostname)
processes=('wazuh-authd' 'wazuh-db' 'wazuh-execd' 'wazuh-analysisd' 'wazuh-syscheckd' 'wazuh-remoted' 'wazuh-logcollector' 'wazuh-monitord' 'wazuh-modulesd')

check_process () {
    #Check process
    if [ -n "$(pgrep $1)" ]; then
        json='{"host":"'"$host"'", "ip_address":"'"$ip_address"'", "wazuhprocess":"$1", "healthy":"yes"}'
        echo -e "$json" >> /tmp/health.json
    else
        #Attempt a restart
        json='{"host":"'"$host"'", "ip_address":"'"$ip_address"'", "wazuhprocess":"$1", "healthy":"attempting_restart"}'
        echo -e "$json" >> /tmp/health.json
        systemctl restart $1
        sleep 5
        if [ -n "$(pgrep $1)" ]; then
            json='{"host":"'"$host"'", "ip_address":"'"$ip_address"'", "wazuhprocess":"$1", "healthy":"yes"}'
            echo -e "$json" >> /tmp/health.json
        else
            json='{"host":"'"$host"'", "ip_address":"'"$ip_address"'", "wazuhprocess":"$1", "healthy":"no"}'
            echo -e "$json" >> /tmp/health.json
        fi
    fi
}

check_agents () {
    agents=$(/var/ossec/bin/agent_control -l -s)
    agents="${agents// /}"
    connected=0
    disconnected=0
    health=yes

    for agent in ${agents[@]}
    do

      data="${agent//,/ }"
      data=( $data )
      status=${data[3]}

      if [[ "$status" = "Active"* ]]
      then

        ((connected+=1))

      elif [[ "$status" = "Disconnected" ]]
      then

        ((disconnected+=1))
        health=no

      fi

      json='{"client_id":"'"${data[0]}"'", "client_name":"'"${data[1]}"'", "client_ip":"'"${data[2]}"'", "client_status":"'"${data[3]}"'", "client_health":"'"$health"'"}'
      echo -e "$json"

    done

    json='{"clients_connected":"'"$connected"'", "clients_disconnected":"'"$disconnected"'"}'
    echo -e "$json"

}

check_wazuh () {
    for process in "${1[@]}"
    do
        check_process $process
    done

    check_agents
}

check_wazuh $processes
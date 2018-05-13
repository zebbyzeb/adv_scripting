#!/bin/bash

#Student Name: Yash Karan Singh
#Student Number : 10445116

#ip_address=$(curl -vs -o /dev/null http://ipecho.net/plain 2>&1) 
#this was to restrict the output of curl to just the ip address. 
#But, for some reason, this doesn't run in this distro.

#ip_address=$(curl http://ipecho.net/plain)
ip_address=$(curl -s http://ipecho.net/plain)
echo "Detecting network location..."

if [[ $ip_address == "139.230"* ]] #ECU's Public IP is of the form 139.230.0.0 as gathered from bgp.he.net
then

    echo "You are on an ECU network"
    echo "Please enter your ECU username"
    read username
    echo "Please enter your ECU password"
    read password
    
    gsettings set org.gnome.system.proxy mode 'manual' 
    gsettings set org.gnome.system.proxy.http host '$username:$password@proxy.ecu.edu.au'
    gsettings set org.gnome.system.proxy.http port 80
	
    cd /etc/

    printf "http_proxy=http://$username:$password@proxy.ecu.edu.au:80/\n\
            https_proxy=http://$username:$password@proxy.ecu.edu.au:80/\n\
            ftp_proxy=http://$username:$password@proxy.ecu.edu.au:80/\n\
            no_proxy=\"localhost,127.0.0.1,localaddress,.localdomain.com\"\n\
            HTTP_PROXY=http://$username:$password@proxy.ecu.edu.au:80/\n\
            HTTPS_PROXY=http://$username:$password@proxy.ecu.edu.au:80/\n\
            FTP_PROXY=http://$username:$password@proxy.ecu.edu.au:80/\n\
            NO_PROXY=\"localhost,127.0.0.1,localaddress,.localdomain.com\"" >> environment

    printf "Acquire::http::proxy \"http://$username:$password@proxy.ecu.edu.au:80\";\n\
            Acquire::ftp::proxy \"ftp://$username:$password@proxy.ecu.edu.au:80\";\n\
            Acquire::https::proxy \"https://$username:$password@proxy.ecu.edu.au:80\";\n" > /etc/apt/apt.conf.d/95proxies

    echo "Your proxy has been set.!"
    echo "You are \"Online\""
  
else
    echo "You are off campus"
    

    gsettings set org.gnome.system.proxy mode 'none'
    cd /etc/apt

    echo "" > apt.conf
	
    echo "" > /etc/apt/apt.conf.d/95proxies
    echo PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games\" > /etc/environment
    
    echo "Proxy settings have been cleared"
    echo "You are \"Online\""



fi

#www.bgp.he.net
#www.ipecho.net/plain

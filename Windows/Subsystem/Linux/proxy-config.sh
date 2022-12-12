#!/usr/bin/env bash

{ # this ensures the entire script is downloaded #

# check if run as root
if [[ $EUID -eq 0 ]]; then
   printErr "This script should not be run as root" 
   exit 1
fi

printfInfo() {
    printf "\033[0;32mINFO:\033[0m %s\n" "$*"
}
printfWarn() {
    printf "\033[0;33mWARN:\033[0m %s\n" "$*"
}

# source string
sourceString=$(cat <<- EOF
# proxy operation
proxy() {
    if [[ \$@ == 'enable' ]]; then
        # Get host ip
        export HOST_IP=$(ip route | grep default | awk '{print $3}');
        export PROXY_PORT=1080;
        export {all_proxy,ALL_PROXY}="socks5://\${HOST_IP}:\${PROXY_PORT}";
        export {ftp_proxy,FTP_PROXY}="http://\${HOST_IP}:\${PROXY_PORT}";
        export {http_proxy,HTTP_PROXY}="http://\${HOST_IP}:\${PROXY_PORT}";
        export {https_proxy,HTTPS_PROXY}="http://\${HOST_IP}:\${PROXY_PORT}";
    elif [[ \$@ == 'disable' ]]; then
        unset {all_proxy,ALL_PROXY};
        unset {ftp_proxy,FTP_PROXY};
        unset {http_proxy,HTTP_PROXY};
        unset {https_proxy,HTTPS_PROXY};
    else
        echo 'all_proxy,   ALL_PROXY   =' \${all_proxy:-'none'};
        echo 'ftp_proxy,   FTP_PROXY   =' \${ftp_proxy:-'none'};
        echo 'http_proxy,  HTTP_PROXY  =' \${http_proxy:-'none'};
        echo 'https_proxy, HTTPS_PROXY =' \${https_proxy:-'none'};
    fi
}

# enable proxy
proxy enable
EOF
)

# configure proxy
if $(grep -qc "proxy operation" ~/.bashrc); then
    printfInfo "Already exists proxy configuration"
else
    printf "\n${sourceString}\n" >> ~/.bashrc
    printfInfo "Successfully append proxy configuration"
    printfWarn "Please restart the terminal to enable proxy"
fi

} # this ensures the entire script is downloaded #

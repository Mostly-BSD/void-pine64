# Per Site Override

installSW() { 
    xbps-install "$@" && echo -e "\nxbps-install $@" >> ~/bootstrap-void.sh
}
enableService() { 
    if [[ -d "/etc/sv/$1" && ! -s "/var/service/$1" ]]; then
        ln -s /etc/sv/$1 /var/service/ && echo "ln -s /etc/sv/$1 /var/service/" >> ~/bootstrap-void.sh;
    fi
}
serviceStatus() {
	if [ -z "$1" ]; then
		sv status /var/service/* | grcat /usr/share/grc/conf.sv
	else
		sv status "$@" | grcat /usr/share/grc/conf.sv
	fi
}
searchSW() {
	xbps-query -R -s "$@" | grcat /usr/share/grc/conf.xbps-query
}

# vim:ft=sh

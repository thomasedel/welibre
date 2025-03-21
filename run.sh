echo "127.0.0.1 marmotte.local" >> /etc/hosts

ssh pve 'pveam update'
#ssh pve 'pveam download local debian-12-standard_12.7-1_amd64.tar.zst'
ssh pve 'pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst'


ssh pve 'pct create 142 /var/lib/vz/template/cache/debian-12-standard_12.7-1_amd64.tar.zst --hostname web --memory 1024 --net0 name=eth0,bridge=vmbr0,firewall=1,gw=10.0.0.254,ip=10.0.0.42/24,type=veth --storage local-lvm --rootfs local-lvm:4 --unprivileged 1 --ignore-unpack-errors --ostype debian --password="rootroot" --start 1'

ssh pve 'pct exec 142 -- apt update'
ssh pve 'pct exec 142 -- apt install apache2 -y'
ssh pve 'pct exec 142 -- wget -O /var/www/html/index.html https://raw.githubusercontent.com/thomasedel/wget/refs/heads/main/index.html'
ssh pve 'pct exec 142 -- service apache2 restart'


ssh pve 'wget -O /etc/nginx/sites-available/bober.conf https://raw.githubusercontent.com/thomasedel/wget/refs/heads/main/marmotte.conf'

ssh pve 'ln -s /etc/nginx/sites-available/bober.conf /etc/nginx/sites-enabled/'

ssh pve 'systemctl restart nginx'

#!/bin/bash

# Installation de packages très très importants

sudo apt update
sudo apt install lolcat curl -y
export PATH=$PATH:/usr/games

curl https://raw.githubusercontent.com/thomasedel/welibre/refs/heads/main/ascii/bonjour.txt | lolcat

USER=${SUDO_USER:-$USER}

echo "127.0.0.1 marmotte.local" | sudo tee -a /etc/hosts > /dev/null

echo "marmotte.local a été ajouté dans les hosts" | lolcat

cid=$(ssh -i /home/$USER/.ssh/cle_tp_admx -p 2222 root@localhost 'pvesh get /cluster/nextid')

ssh -i /home/$USER/.ssh/cle_tp_admx -p 2222 root@localhost 'sudo pveam update'

ssh -i /home/$USER/.ssh/cle_tp_admx -p 2222 root@localhost 'sudo pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst'

echo "L'image ubuntu pour le conteneur a été téléchargée" | lolcat

ssh -i /home/$USER/.ssh/cle_tp_admx -p 2222 root@localhost "sudo pct create $cid /var/lib/vz/template/cache/debian-12-standard_12.7-1_amd64.tar.zst --hostname web --memory 1024 --net0 name=eth0,bridge=vmbr0,firewall=1,gw=10.0.0.254,ip=10.0.0.42/24,type=veth --storage local-lvm --rootfs local-lvm:4 --unprivileged 1 --ignore-unpack-errors --ostype debian --password=\"rootroot\" --start 1"

echo "Conteneur créé" | lolcat

ssh -i /home/$USER/.ssh/cle_tp_admx -p 2222 root@localhost "sudo pct exec $cid -- apt update"
ssh -i /home/$USER/.ssh/cle_tp_admx -p 2222 root@localhost "sudo pct exec $cid -- apt install apache2 -y"

ssh -i /home/$USER/.ssh/cle_tp_admx -p 2222 root@localhost "sudo pct exec $cid -- wget -O /var/www/html/index.html https://raw.githubusercontent.com/thomasedel/welibre/refs/heads/main/S1_proxmox/index.html"

ssh -i /home/$USER/.ssh/cle_tp_admx -p 2222 root@localhost "sudo pct exec $cid -- service apache2 restart"

echo "Apache installé, site louche déployé" | lolcat

ssh -i /home/$USER/.ssh/cle_tp_admx -p 2222 root@localhost 'sudo wget -O /etc/nginx/sites-available/bober.conf https://raw.githubusercontent.com/thomasedel/welibre/refs/heads/main/S1_proxmox/marmotte.conf'

ssh -i /home/$USER/.ssh/cle_tp_admx -p 2222 root@localhost 'sudo ln -s /etc/nginx/sites-available/bober.conf /etc/nginx/sites-enabled/'

ssh -i /home/$USER/.ssh/cle_tp_admx -p 2222 root@localhost 'sudo systemctl restart nginx'

echo "Nginx Proxmox configuré" | lolcat

curl https://raw.githubusercontent.com/thomasedel/welibre/refs/heads/main/ascii/goose.txt | lolcat
echo "Rendez-vous ici : http://marmotte.local:8080" | lolcat

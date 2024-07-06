#!/bin/bash
#Url: https://dev.to/mustafazaimoglu/creating-package-specific-local-repository-in-rocky-linux-9-1g9k

echo "10.10.10.1 BDD1 BDD1.technobrain.com" >> /etc/hosts
echo "10.10.10.2 BDD2 BDD2.technobrain.com" >> /etc/hosts
echo "10.10.10.3 BDD3 BDD3.technobrain.com" >> /etc/hosts
echo "10.10.10.4 maxscale maxscale.technobrain.com" >> /etc/hosts
echo "10.10.10.5 keycloak keycloak.technobrain.com" >> /etc/hosts
echo "10.10.10.200 Depot Depot.technobrain.com" >> /etc/hosts

########## Git Cli ##############
#dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
#dnf install gh
#gh auth login

############ Install repos server ###############
dnf update -y
#dnf install -y yum-utils createrepo
dnf install -y sshpass

############# download conf #################

sshpass -p toto ssh -o StrictHostKeyChecking=no toto@localhost << EOF
git clone https://github.com/ArnodTOTO/Mariadb-galera-maxscale.git
wget https://github.com/keycloak/keycloak/releases/download/25.0.1/keycloak-25.0.1.zip
exit
EOF

######## Create http server in python ######## 
cd /home/toto/
sshpass -p toto scp -o StrictHostKeyChecking=no Mariadb-galera-maxscale/deploiement_BDD1.sh toto@BDD1:~/

sshpass -p toto scp -o StrictHostKeyChecking=no Mariadb-galera-maxscale/compl-BDD2.sh toto@BDD2:~/

sshpass -p toto scp -o StrictHostKeyChecking=no Mariadb-galera-maxscale/compl-BDD3.sh toto@BDD3:~/

sshpass -p toto scp -o StrictHostKeyChecking=no Mariadb-galera-maxscale/maxscale.sh toto@maxscale:~/

sshpass -p toto scp -o StrictHostKeyChecking=no Mariadb-galera-maxscale/keycloak.sh toto@keycloak:~/

#cd repos/
#systemctl stop firewalld.service
#python3 -m http.server 8080 &
#sleep 2

############## launch BDD1 ###############
sshpass -p root ssh -o StrictHostKeyChecking=no root@BDD1 << EOF
cd /home/toto
chmod +x deploiement_BDD1.sh
./deploiement_BDD1.sh
exit
EOF

############## launch BDD2 ###############
sshpass -p root ssh -o StrictHostKeyChecking=no root@BDD2 << EOF
cd /home/toto
chmod +x compl-BDD2.sh
./compl-BDD2.sh
exit
EOF

############## launch BDD3 ###############
sshpass -p root ssh -o StrictHostKeyChecking=no root@BDD3 << EOF
cd /home/toto
chmod +x compl-BDD3.sh
./compl-BDD3.sh
exit
EOF

############## launch maxscale ###############
sshpass -p root ssh -o StrictHostKeyChecking=no root@maxscale << EOF
cd /home/toto
chmod +x maxscale.sh
./maxscale.sh
exit
EOF

############## launch BDD2 ###############
sshpass -p root ssh -o StrictHostKeyChecking=no root@keycloak << EOF
cd /home/toto
chmod +x keycloak.sh
./keycloak.sh
exit
EOF

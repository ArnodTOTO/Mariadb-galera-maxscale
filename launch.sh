#!/bin/bash
#Url: https://dev.to/mustafazaimoglu/creating-package-specific-local-repository-in-rocky-linux-9-1g9k


########## Git Cli ##############
#dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
#dnf install gh
#gh auth login

#git clone https://github.com/ArnodTOTO/Mariadb-galera-maxscale.git


source ./env_password_launch

echo "10.10.10.1 BDD1 BDD1.technobrain.com" >> /etc/hosts
echo "10.10.10.2 BDD2 BDD2.technobrain.com" >> /etc/hosts
echo "10.10.10.3 BDD3 BDD3.technobrain.com" >> /etc/hosts
echo "10.10.10.4 maxscale maxscale.technobrain.com" >> /etc/hosts
echo "10.10.10.5 keycloak keycloak.technobrain.com" >> /etc/hosts
echo "10.10.10.200 Depot Depot.technobrain.com" >> /etc/hosts



############ Install repos server ###############
dnf update -y
#dnf install -y yum-utils createrepo
dnf install -y sshpass

############# download conf #################

sshpass -p ${password_toto} ssh -o StrictHostKeyChecking=no toto@localhost << EOF
wget https://github.com/keycloak/keycloak/releases/download/25.0.1/keycloak-25.0.1.zip
wget https://dlm.mariadb.com/3820095/MariaDB/mariadb-11.2.4/yum/rhel/mariadb-11.2.4-rhel-9-x86_64-rpms.tar
exit
EOF

######## Create http server in python ######## 
cd /home/toto/
sshpass -p ${password_root} scp -o StrictHostKeyChecking=no Mariadb-galera-maxscale/deploiement_BDD1.sh root@BDD1:~/
sshpass -p ${password_root} scp  Mariadb-galera-maxscale/private/* root@BDD1:~/
sshpass -p ${password_root} scp  Mariadb-galera-maxscale/env/env_password_BDD root@BDD1:~/


sshpass -p ${password_root} scp -o StrictHostKeyChecking=no Mariadb-galera-maxscale/compl-BDD2.sh root@BDD2:~/
sshpass -p ${password_root} scp  Mariadb-galera-maxscale/private/* root@BDD2:~/
sshpass -p ${password_root} scp  Mariadb-galera-maxscale/env/env_password_BDD root@BDD2:~/


sshpass -p ${password_root} scp -o StrictHostKeyChecking=no Mariadb-galera-maxscale/compl-BDD3.sh root@BDD3:~/
sshpass -p ${password_root} scp  Mariadb-galera-maxscale/private/* root@BDD3:~/
sshpass -p ${password_root} scp  Mariadb-galera-maxscale/env/env_password_BDD root@BDD3:~/


sshpass -p ${password_root} scp -o StrictHostKeyChecking=no Mariadb-galera-maxscale/maxscale.sh root@maxscale:~/
sshpass -p ${password_root} scp  Mariadb-galera-maxscale/private/* root@maxscale:~/
sshpass -p ${password_root} scp  Mariadb-galera-maxscale/maxscale/* root@maxscale:~/
sshpass -p ${password_root} scp  Mariadb-galera-maxscale/env/env_password_maxscale root@maxscale:~/

sshpass -p ${password_root} scp -o StrictHostKeyChecking=no Mariadb-galera-maxscale/keycloak.sh root@keycloak:~/
sshpass -p ${password_root} scp  Mariadb-galera-maxscale/private/* root@keycloak:~/
sshpass -p ${password_root} scp  Mariadb-galera-maxscale/keycloak/* root@keycloak:~/
sshpass -p ${password_root} scp  Mariadb-galera-maxscale/env_password_keycloak root@keycloak:~/

#cd repos/
#systemctl stop firewalld.service
#python3 -m http.server 8080 &
#sleep 2

############## launch BDD1 ###############
sshpass -p ${password_root} ssh -o StrictHostKeyChecking=no root@BDD1 << EOF
chmod 600 private_key.pem
cd /home/toto
chmod +x ~/deploiement_BDD1.sh
/root/deploiement_BDD1.sh
exit
EOF

############## launch BDD2 ###############
sshpass -p ${password_root} ssh -o StrictHostKeyChecking=no root@BDD2 << EOF
chmod 600 private_key.pem
cd /home/toto
chmod +x ~/compl-BDD2.sh
/root/compl-BDD2.sh
exit
EOF

############## launch BDD3 ###############
sshpass -p ${password_root} ssh -o StrictHostKeyChecking=no root@BDD3 << EOF
chmod 600 private_key.pem
cd /home/toto
chmod +x ~/compl-BDD3.sh
/root/compl-BDD3.sh
exit
EOF

############## launch maxscale ###############
sshpass -p ${password_root} ssh -o StrictHostKeyChecking=no root@maxscale << EOF
chmod 600 private_key.pem
cd /home/toto
chmod +x ~/maxscale.sh
/root/maxscale.sh
exit
EOF

############## launch keycloak ###############
sshpass -p ${password_root} ssh -o StrictHostKeyChecking=no root@keycloak << EOF
chmod 600 private_key.pem
cd /home/toto
chmod +x ~/keycloak.sh
/root/keycloak.sh
exit
EOF

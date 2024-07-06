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
dnf install -y yum-utils createrepo


########## download repos galera #########
wget https://dlm.mariadb.com/3820095/MariaDB/mariadb-11.2.4/yum/rhel/mariadb-11.2.4-rhel-9-x86_64-rpms.tar
tar xvf mariadb-11.2.4-rhel-9-x86_64-rpms.tar
cd mariadb-11.2.4-rhel-9-x86_64-rpms/
./setup_repository
cd ../
mkdir repos
cd repos
mkdir mariadb-server
cd mariadb-server
repotrack --downloaddir=$PWD mariadb-server
createrepo $PWD

######### download repos mysql-selinux #######
cd ../
mkdir mysql-selinux
cd mysql-selinux
repotrack --downloaddir=$PWD mysql-selinux
createrepo $PWD

######### download repos java-21-openjdk #######
cd ../
mkdir java-21-openjdk
cd java-21-openjdk
repotrack --downloaddir=$PWD java-21-openjdk
createrepo $PWD

######### download repos java-21-openjdk #######
cd ../
mkdir sshpass
cd sshpass
repotrack --downloaddir=$PWD sshpass
createrepo $PWD


######### download mariadb-tools #######
curl -LsS https://r.mariadb.com/downloads/mariadb_repo_setup | bash
cd ../
mkdir maxscale
cd maxscale
repotrack --downloaddir=$PWD maxscale
createrepo $PWD


dnf install -y sshpass
#sshpass -p root ssh -o StrictHostKeyChecking=no root@BDD1 << EOF
#mkdir -p /etc/yum.repos.d/old
#mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/old/
#exit
#EOF

############# download conf #################

sshpass -p toto ssh -o StrictHostKeyChecking=no toto@localhost << EOF
git clone https://github.com/ArnodTOTO/Mariadb-galera-maxscale.git
wget https://github.com/keycloak/keycloak/releases/download/25.0.1/keycloak-25.0.1.zip
exit
EOF

######## Create http server in python ######## 
cd /home/toto/
sshpass -p toto scp -o StrictHostKeyChecking=no Mariadb-galera-maxscale/repos/* toto@BDD1:~/
sshpass -p toto scp Mariadb-galera-maxscale/deploiement_BDD1.sh toto@BDD1:~/

sshpass -p toto scp -o StrictHostKeyChecking=no Mariadb-galera-maxscale/repos/* toto@BDD2:~/
sshpass -p toto scp Mariadb-galera-maxscale/compl-BDD2.sh toto@BDD2:~/

sshpass -p toto scp -o StrictHostKeyChecking=no Mariadb-galera-maxscale/repos/* toto@BDD3:~/
sshpass -p toto scp Mariadb-galera-maxscale/compl-BDD3.sh toto@BDD3:~/

sshpass -p toto scp -o StrictHostKeyChecking=no Mariadb-galera-maxscale/repos/* toto@maxscale:~/
sshpass -p toto scp Mariadb-galera-maxscale/maxscale.sh toto@maxscale:~/

sshpass -p toto scp -o StrictHostKeyChecking=no Mariadb-galera-maxscale/repos/* toto@keycloak:~/
sshpass -p toto scp Mariadb-galera-maxscale/keycloak.sh toto@keycloak:~/

cd repos/
systemctl stop firewalld.service
python3 -m http.server 8080 &
sleep 2

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

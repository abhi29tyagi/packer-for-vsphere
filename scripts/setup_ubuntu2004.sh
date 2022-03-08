#!/usr/bin/bash

# Prepares a Ubuntu Server guest operating system.

# ### Update the guest operating system. ###
echo '> Updating the guest operating system ...'
sudo apt-get update
sudo apt-get -y upgrade

cat << 'EOL' | sudo tee /etc/rc.local
#!/bin/sh -ef
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.
#
# dynamically create hostname (optional)
#if hostname | grep localhost; then
#    hostnamectl set-hostname "$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')"
#fi

# Generate SSH keys on boot for an ubuntu image
test -f /etc/ssh/ssh_host_dsa_key || dpkg-reconfigure openssh-server
exit 0

EOL

# make sure the script is executable
chmod +x /etc/rc.local

### Create a cleanup script. ###
echo '> Creating cleanup script ...'
sudo cat <<EOF > /tmp/cleanup.sh
#!/bin/bash
# Cleans all audit logs.
echo '> Cleaning all audit logs ...'
if [ -f /var/log/audit/audit.log ]; then
cat /dev/null > /var/log/audit/audit.log
fi
if [ -f /var/log/wtmp ]; then
cat /dev/null > /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
cat /dev/null > /var/log/lastlog
fi
# Cleans persistent udev rules.
echo '> Cleaning persistent udev rules ...'
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
rm /etc/udev/rules.d/70-persistent-net.rules
fi
# Cleans /tmp directories.
echo '> Cleaning /tmp directories ...'
rm -rf /tmp/*
rm -rf /var/tmp/*
# Cleans SSH keys.
echo '> Cleaning SSH keys ...'
rm -f /etc/ssh/ssh_host_*
# Sets hostname to localhost.
echo '> Setting hostname to localhost ...'
cat /dev/null > /etc/hostname
hostnamectl set-hostname localhost
# Cleans apt-get.
echo '> Cleaning apt-get ...'
apt-get clean
apt-get autoremove
# Cleans the machine-id.
echo '> Cleaning the machine-id ...'
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id
# Cleans shell history.
echo '> Cleaning shell history ...'
unset HISTFILE
history -cw
echo '> ~/.bash_history'
rm -fr /root/.bash_history
# Cloud Init Nuclear Option
rm -rf /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg
rm -rf /etc/cloud/cloud.cfg.d/99-installer.cfg
echo "disable_vmware_customization: false" >> /etc/cloud/cloud.cfg
echo "# to update this file, run dpkg-reconfigure cloud-init
datasource_list: [ VMware, OVF, None ]" > /etc/cloud/cloud.cfg.d/90_dpkg.cfg
# Set boot options to not override what we are sending in cloud-init
echo '> modifying grub'
sed -i -e "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/" /etc/default/grub
sudo update-grub
EOF

### Change script permissions for execution. ### 
echo '> Changeing script permissions for execution ...'
sudo chmod +x /tmp/cleanup.sh


### Executes the cleauup script. ### 
echo '> Executing the cleanup script ...'
sudo /tmp/cleanup.sh

### All done. ### 
echo '> Done.'  

# Install docker
apt update -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
apt update -y
apt-cache policy docker-ce
apt install docker-ce -y
usermod -aG docker svc-compute-packagin

# I have following tools also as part of my VM template. Feel free to ignore them or add some as per your use-case.    
# Install CLIs - jfrog-cli and helix-cli
wget -qO - https://releases.jfrog.io/artifactory/jfrog-gpg-public/jfrog_public_gpg.key | sudo apt-key add -
echo "deb https://releases.jfrog.io/artifactory/jfrog-debs xenial contrib" | sudo tee -a /etc/apt/sources.list;
wget -qO - https://package.perforce.com/perforce.pubkey | sudo apt-key add -
echo "deb http://package.perforce.com/apt/ubuntu focal release" | sudo tee /etc/apt/sources.list.d/perforce.list
sudo apt-get update
sudo apt-get install -y jfrog-cli-v2-jf
sudo apt-get install -y helix-p4d

# Install package createrepo - which creates RPM repositories and is not supported in Ubuntu 20.04 LTS by default
# This package is being re-written in C as createrepo-c and should be available from 21.04 onwards
# workaround:
URL=("http://ports.ubuntu.com/pool/main/u/urlgrabber/python-urlgrabber_3.10.2-1_all.deb" "http://ftp.de.debian.org/debian/pool/main/y/yum/yum_3.4.3-3_all.deb" "http://ftp.de.debian.org/debian/pool/main/y/yum-metadata-parser/python-sqlitecachec_1.1.4-1_amd64.deb" "http://archive.ubuntu.com/ubuntu/pool/universe/p/python-lzma/python-lzma_0.5.3-3_amd64.deb" "http://archive.ubuntu.com/ubuntu/pool/universe/d/deltarpm/python-deltarpm_3.6+dfsg-1build6_amd64.deb" "http://archive.ubuntu.com/ubuntu/pool/universe/d/deltarpm/deltarpm_3.6+dfsg-1build6_amd64.deb" "http://ftp.de.debian.org/debian/pool/main/c/createrepo/createrepo_0.10.3-1_all.deb")
# shellcheck disable=SC2068
for url in ${URL[@]};
do
  wget "$url" -P /tmp/
done
sudo apt-get install -y /tmp/createrepo_0.10.3-1_all.deb /tmp/deltarpm_3.6+dfsg-1build6_amd64.deb /tmp/python-deltarpm_3.6+dfsg-1build6_amd64.deb /tmp/python-lzma_0.5.3-3_amd64.deb /tmp/python-sqlitecachec_1.1.4-1_amd64.deb /tmp/yum_3.4.3-3_all.deb /tmp/python-urlgrabber_3.10.2-1_all.deb

echo '> Packer Template Build -- Complete'


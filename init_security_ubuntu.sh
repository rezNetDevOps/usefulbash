#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
	echo "Please run this script as root"
	exit
fi

# install vim and add plugins
echo "Take care of Vim"
git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

# Update package repositories and upgrade installed packages
echo "Updating package repositories and upgrading installed packages..."
apt-get -y update && apt-get -y upgrade

# useradd -m -G sudo -s /bin/bash jenkins && passwd -d jenkins
# mkdir /home/jenkins/.ssh
# cp ~/.ssh/authorized_keys /home/jenkins/.ssh/
# chown -R jenkins:jenkins /home/jenkins/.ssh/

# Enable firewall (UFW) and allow SSH, HTTP, and HTTPS traffic
echo "Configuring firewall (UFW)..."
ufw allow OpenSSH
ufw allow http
ufw allow https
ufw --force enable

# Disable root login via SSH
echo "Disabling root login via SSH..."
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Disable password authentication and use SSH key-based authentication
echo "Disabling password authentication and configuring SSH key-based authentication..."
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Install and configure Fail2ban to prevent brute force attacks
echo "Installing and configuring Fail2ban..."
apt install -y fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
systemctl enable fail2ban
systemctl start fail2ban

# Install and configure auditd for auditing system changes
echo "Installing and configuring auditd for system auditing..."
apt install -y auditd
systemctl enable auditd
systemctl start auditd

# Enable automatic security updates
echo "Enabling automatic security updates..."
apt install -y unattended-upgrades
dpkg-reconfigure --priority=low unattended-upgrades

# Set password expiration policy
echo "Configuring password expiration policy..."
sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t90/' /etc/login.defs
sed -i 's/PASS_MIN_DAYS\t0/PASS_MIN_DAYS\t7/' /etc/login.defs

# Install and configure log monitoring tools like Logwatch or Logcheck (optional)
#echo "Installing and configuring log monitoring tools..."
#apt install -y logwatch

# Install and configure an intrusion detection system (IDS) such as OSSEC (optional)
#echo "Installing and configuring an intrusion detection system (IDS)..."
#apt install -y ossec-hids-server

# Enable filesystem integrity checking with AIDE (optional)
#echo "Enabling filesystem integrity checking with AIDE..."
#apt install -y aide
#aideinit
#cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# Set proper permissions on sensitive files and directories
echo "Setting proper permissions on sensitive files and directories..."
chmod 0700 /root
chmod 0700 /etc/ssh
chmod 0600 /etc/ssh/sshd_config

# Disable unnecessary services
echo "Disabling unnecessary services..."
systemctl disable avahi-daemon
systemctl disable bluetooth
systemctl disable cups

# Remove unnecessary packages
echo "Removing unnecessary packages..."
apt autoremove -y

# Reboot the server for changes to take effect
echo "Server will reboot in 1 minute..."
sleep 60
reboot

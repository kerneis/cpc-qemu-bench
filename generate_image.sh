# on the host
wget http://cdimage.debian.org/debian-cd/7.1.0/i386/iso-cd/debian-7.1.0-i386-netinst.iso
qemu-img create testbedhdd.img 5G -f qcow2
qemu testbedhdd.img -cdrom debian-7.1.0-i386-netinst.iso -boot d
qemu -hda testbedhdd.img -redir tcp:2222::22

# generate keys (already in repo)
ssh-keygen

# on the guest

# install necessary packages
vi /etc/apt/sources.list
# need to add lines:
# deb http://ftp.uk.debian.org/debian/ wheezy main contrib non-free
# deb-src http://ftp.uk.debian.org/debian/ wheezy main contrib non-free
apt-get install sudo less fio dropbear
apt-get install --no-install-recommends openssh-client

# install ssh key
mkdir .ssh
mv cpc-test.rsa.pub .ssh/authorized_keys

# add cpctest to sudoers group
groupmod -a -G sudo cpctest

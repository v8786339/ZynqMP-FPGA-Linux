
#### Setup APT

distro=buster
export LANG=C

/debootstrap/debootstrap --second-stage

cat <<EOT > /etc/apt/sources.list
deb     http://ftp.jp.debian.org/debian            buster         main contrib non-free
deb-src http://ftp.jp.debian.org/debian            buster         main contrib non-free
deb     http://ftp.jp.debian.org/debian            buster-updates main contrib non-free
deb-src http://ftp.jp.debian.org/debian            buster-updates main contrib non-free
deb     http://security.debian.org/debian-security buster/updates main contrib non-free
deb-src http://security.debian.org/debian-security buster/updates main contrib non-free
EOT

cat <<EOT > /etc/apt/apt.conf.d/71-no-recommends
APT::Install-Recommends "0";
APT::Install-Suggests   "0";
EOT

apt-get update  -y

#### Install Core applications

apt-get install -y locales dialog
dpkg-reconfigure locales
apt-get install -y net-tools openssh-server ntpdate resolvconf sudo less hwinfo ntp tcsh zsh file

#### Setup hostname

echo "debian-fpga" > /etc/hostname

#### Set root password

echo Set root password
passwd

cat <<EOT >> /etc/securetty
# Seral Port for Xilinx Zynq
ttyPS0
EOT

#### Add fpga user

echo Add fpga user
adduser fpga
echo "fpga ALL=(ALL:ALL) ALL" > /etc/sudoers.d/fpga

#### Setup sshd config

sed -i -e 's/#PasswordAuthentication/PasswordAuthentication/g' /etc/ssh/sshd_config

#### Setup Time Zone

dpkg-reconfigure tzdata

#### Setup fstab

cat <<EOT > /etc/fstab
none		/config		configfs	defaults	0	0
EOT

#### Setup Network Interface

cat <<EOT > /etc/network/interfaces.d/eth0
allow-hotplug eth0
iface eth0 inet dhcp
EOT

#### Setup /lib/firmware

mkdir /lib/firmware
mkdir /lib/firmware/ti-connectivity
mkdir /lib/firmware/mchp

#### Install Development applications

apt-get install -y build-essential
apt-get install -y pkg-config
apt-get install -y git
apt-get install -y u-boot-tools
apt-get install -y libssl-dev
apt-get install -y socat
apt-get install -y ruby rake ruby-msgpack ruby-serialport
apt-get install -y python  python-dev  python-setuptools  python-wheel  python-pip  
apt-get install -y python3 python3-dev python3-setuptools python3-wheel python3-pip
apt-get install -y python-numpy python3-numpy
pip3 install msgpack-rpc-python
apt-get install -y flex bison
apt-get install -y device-tree-compiler

#### Install Wireless tools and firmware

apt-get install -y wireless-tools
apt-get install -y wpasupplicant
apt-get install -y firmware-realtek
apt-get install -y firmware-ralink

git clone git://git.ti.com/wilink8-wlan/wl18xx_fw.git
cp wl18xx_fw/wl18xx-fw-4.bin /lib/firmware/ti-connectivity
rm -rf wl18xx_fw/

git clone git://git.ti.com/wilink8-bt/ti-bt-firmware
cp ti-bt-firmware/TIInit_11.8.32.bts /lib/firmware/ti-connectivity
rm -rf ti-bt-firmware

git clone git://github.com/linux4wilc/firmware  linux4wilc-firmware  
cp linux4wilc-firmware/*.bin /lib/firmware/mchp
rm -rf linux4wilc-firmware  

#### Install Other applications

apt-get install -y avahi-daemon
apt-get install -y samba

#### Install haveged for Linux Kernel 4.19

apt-get install -y haveged

#### Install Linux Modules

dpkg -i linux-image-4.19.0-xlnx-v2019.2-zynqmp-fpga_4.19.0-xlnx-v2019.2-zynqmp-fpga-2_arm64.deb

#### Clean Cache

apt-get clean

##### Create Debian Package List

dpkg -l > dpkg-list.txt

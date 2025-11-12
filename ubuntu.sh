#!/data/data/com.termux/files/usr/bin/bash
# <=> https://github.com/wahasa

# Ubuntu Release
# <=> https://ubuntu.com
# <=> https://releases.ubuntu.com
# <=> https://ubuntu.com/about/release-cycle

# Ubuntu ESM ( Extended Security Maintenance )
# [+] trusty 14.04 lts ( Trusty Tahr )
# [+] xenial 16.04 lts ( Xenial Xerus )
# [+] bionic 18.04 lts ( Bionic Beaver )
# [+] focal  20.04 lts ( Focal Fossa )

# Ubuntu LTS ( Long Term Support )
# [+] jammy  22.04 lts ( Jammy Jellyfish )
# [+] noble  24.04 lts ( Noble Numbat )

# Ubuntu Lastest
# [+] plucky     25.04 ( Plucky Puffin )
# [+] resolute   26.04 (Resolute Raccoon)

# Ubuntu Next
# [+] questing   25.10 ( Questing Quokka ) - ( Next Release )

# Ubuntu Devel
# [+] devel      Next  ( Development )

# Ubuntu Repositories
# <=> http://ports.ubuntu.com/ubuntu-ports/dists

# Ubuntu Rootfs
# <=> https://partner-images.canonical.com/oci
# <=> https://partner-images.canonical.com/core
# <=> https://cdimage.ubuntu.com/ubuntu-base
# <=> https://hub.docker.com/_/ubuntu

# Regular Colors
blk="\033[0;30m"       # Black
red="\033[0;31m"       # Red
grn="\033[0;32m"       # Green
ylw="\033[0;33m"       # Yellow
blu="\033[0;34m"       # Blue
ppl="\033[0;35m"       # Purple
cyn="\033[0;36m"       # Cyan
wht="\033[0;37m"       # White
rst="\033[0m"          # Reset

clear
printf "${blu} • Welcome To Ubuntu Termux For Android\n"
printf "\n"
printf "${blu}List Code Name     Version     Recommended\n"
#printf"${red}[+]  ${red}devel          ${red}16.04          ${red}no \n"
printf "${grn}[+]  ${ylw}questing       ${wht}25.10          ${grn}yes\n"
printf "${grn}[+]  ${ylw}plucky         ${wht}25.04          ${grn}yes\n"
printf "${grn}[+]  ${ylw}oracular       ${wht}24.10          ${grn}yes\n"
printf "${grn}[+]  ${ylw}noble          ${wht}24.04          ${grn}yes\n"
printf "${grn}[+]  ${ylw}jammy          ${wht}22.04          ${grn}yes\n"
printf "${grn}[+]  ${ylw}focal          ${wht}20.04          ${grn}yes\n"
printf "${grn}[+]  ${ylw}bionic         ${wht}18.04          ${grn}yes\n"
#printf"${red}[+]  ${red}xenial         ${red}16.04          ${red}no \n"
#printf"${red}[+]  ${red}trusty         ${red}14.04          ${red}no \n"
printf "${blu}\n"
printf "${cyn}Select your ubuntu < ${ylw}code name${cyn} > :${ylw}"
read -p " " ubuntu

clear
bin=.ubuntu
linux=ubuntu
   printf "${rst}\n"
   printf "${grn}Installing $linux $ubuntu,..\n"
   printf "${rst}\n"
   pkg install root-repo x11-repo
   pkg install proot neofetch pulseaudio -y
   #termux-setup-storage
   printf "${rst}\n"
folder=ubuntu-fs
neofetch --ascii_distro $linux -L
if [ -d "$folder" ]; then
        first=1
        printf "${red}Ubuntu has been installed on $folder.${rst}\n"
        printf "\n" ; exit
fi
tarball="ubuntu-rootfs.tar.gz"
if [ "$first" != 1 ];then
        if [ ! -f $tarball ]; then
        printf "${grn}Downloading rootfs, please wait,..${rst}\n"
        printf "\n"
               case `dpkg --print-architecture` in
               aarch64)
                       archurl="arm64" ;;
               arm*)
                       archurl="armhf" ;;
               #i386)
               #       archurl="i386" ;;
               #x86_64)
               #       archurl="amd64" ;;
               *)
               printf "${red}Unknown architecture.\n"
               printf "\n" ; exit 1 ;;
               esac
               wget "https://partner-images.canonical.com/oci/${ubuntu}/current/ubuntu-${ubuntu}-oci-${archurl}-root.tar.gz" -O $tarball
        fi
        mkdir -p $folder
        mkdir -p $folder/binds
        printf "${cyn}Extracting rootf, please wait,..${rst}\n"
        proot --link2symlink tar -xpf ~/${tarball} -C ~/$folder/ --exclude='dev' ||:
   fi
   echo "localhost" > $folder/etc/hostname
   echo "127.0.0.1 localhost" > $folder/etc/hosts
   echo "nameserver 8.8.8.8" > $folder/etc/resolv.conf
   mkdir -p $folder/home/$linux
sleep 2
printf "\n"
printf "${ylw}Writing script to login.....[${grn}ok${ylw}]${rst}\n"
cat > $bin <<- EOM
#!/data/data/com.termux/files/usr/bin/bash
cd \$(dirname \$0)
## Audio output script in pulseaudio termux.
pulseaudio --start --load="module-aaudio-sink" --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
## Unset LD_PRELOAD in case termux-exec is installed.
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" --kill-on-exit"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A $folder/binds)" ]; then
   for f in $folder/binds/* ;do
       . \$f
   done
fi
command+=" -b /dev"
command+=" -b /dev/urandom:/dev/random"
command+=" -b /proc"
command+=" -b /proc/self/fd:/dev/fd"
command+=" -b /proc/self/fd/0:/dev/stdin"
command+=" -b /proc/self/fd/1:/dev/stdout"
command+=" -b /proc/self/fd/2:/dev/stderr"
command+=" -b /dev/null:/proc/sys/kernel/cap_last_cap"
command+=" -b /:/host-rootfs"
command+=" -b /sys"
command+=" -b /sys/fs/selinux"
command+=" -b $folder/tmp:/dev/shm"
## Uncomment the following line to get access to termux directory.
command+=" -b /data/data/com.termux/files/home:/home/$linux"
## Uncomment the following line to mount sdcard directly to linux.
command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" MOZ_FAKE_NO_SANDBOX=1"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
command+=" TERM=${TERM-xterm-256color}"
command+=" TMPDIR=/tmp"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com=" \$@"
if [ -z "\$1" ];then
   exec \$command
else
   \$command -c "\$com"
fi
EOM
   sleep 1
   printf "${ylw}Fixing shebang of $linux....[${grn}ok${ylw}]\n"
   termux-fix-shebang $bin
   sleep 1
   printf "${ylw}Making executable $linux....[${grn}ok${ylw}]\n"
   chmod +x $bin
   sleep 1
   printf "${ylw}Fixing permissions $linux...[${grn}ok${ylw}]\n"
   #chmod -R 755 $folder
   sleep 1
   printf "${ylw}Removing rootfs in termux...[${grn}ok${ylw}]\n"
   rm $tarball
sleep 2
printf "\n"
printf "\n"
printf "${cyn}Please, create your new username${rst}\n"
sleep 1
printf "${grn}Input username${rst}\n"
read -p " " user
sleep 2
printf "\n"
printf "${grn}Input password${rst}\n"
read -p " " pass
   sleep 1
   printf "\n"
   printf "\n"
   printf "${red}Updating package,..${rst}\n"
   printf "\n"
echo "" > $folder/root/.hushlogin
echo "TZ='Asia/Jakarta'; export TZ" >> $folder/root/.profile
cat > $PREFIX/bin/$linux <<- EOF
bash .$linux
EOF
chmod +x $PREFIX/bin/$linux
cat > $folder/root/.bash_profile <<- EOF
apt update ; apt upgrade -y
ln -s /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
apt install apt-utils dialog nano sudo tzdata -y
useradd -m -s /bin/bash $user
usermod -aG sudo $user
echo "$user:$pass" | chpasswd
echo "$user  ALL=(ALL:ALL) ALL" > /etc/sudoers.d/$user
rm -rf ~/.bash_profile
exit
EOF
bash $bin
cat > $PREFIX/bin/$linux <<- EOF
bash .$linux su $user
EOF
cp $folder/etc/skel/.bashrc $folder/home/$user
echo "TZ='Asia/Jakarta'; export TZ" >> $folder/home/$user/.profile
echo "export PULSE_SERVER=127.0.0.1 ; cd" >> $folder/home/$user/.bashrc
#sed -i 's/32/31/g' $folder/home/$user/.bashrc
echo "" > $folder/home/$user/.hushlogin
   clear
   printf "\n"
   printf "${cyn}You can login to Linux with '${grn}$linux${cyn}' script next time.${rst}\n"
   printf "\n"
   #rm ubuntu.sh
#
## Script edited by 'WaHaSa', Script revision-6.
#

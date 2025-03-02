#!/data/data/com.termux/files/usr/bin/bash
# Ubuntu Linux
# <=> https://ubuntu.com

# Ubuntu ESM ( Extended Security Maintenance )
# [+] trusty 14.04 lts ( Trusty Tahr )
# [+] xenial 16.04 lts ( Xenial Xerus )
# [+] bionic 18.04 lts ( Bionic Beaver )

# Ubuntu LTS ( Long term support )
# [+] focal  20.04 lts ( Focal Fossa )
# [+] jammy  22.04 lts ( Jammy Jellyfish )
# [+] noble  24.04 lts ( Noble Numbat )

# Ubuntu Release
# [+] oracular 24.10 ( Oracular Oriole )
# [+] plucky   25.04 ( Plucky Puffin )

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
printf "${blu} • Lists ubuntu release\n"
printf "\n"
printf "${blu}<=> Code Name     Version     Recommended\n"
printf "${cyn}[+] ${ylw}plucky        ${wht}25.04       ${grn}yes\n"
printf "${cyn}[+] ${ylw}oracular      ${wht}24.10       ${grn}yes\n"
printf "${cyn}[+] ${ylw}noble         ${wht}24.04       ${grn}yes\n"
printf "${cyn}[+] ${ylw}jammy         ${wht}22.04       ${grn}yes\n"
printf "${cyn}[+] ${ylw}focal         ${wht}20.04       ${grn}yes\n"
printf "${cyn}[+] ${ylw}bionic        ${wht}18.04       ${grn}yes\n"
printf "${cyn}[+] ${ylw}xenial        ${wht}16.04       ${red}no\n"
printf "${cyn}[+] ${ylw}trusty        ${wht}14.04       ${red}no\n"
printf "${blu}\n"

read -p "Select your ubuntu < code name > : " ubuntu

printf "${rst}\n"
pkg install root-repo x11-repo
pkg install proot neofetch pulseaudio -y
#termux-setup-storage
echo ""
neofetch --ascii_distro Ubuntu -L
folder=ubuntu-fs
if [ -d "$folder" ]; then
         first=1
         printf "${red}Skipping Downloading.${rst}\n"
fi
tarball="ubuntu-rootfs.tar.gz"
if [ "$first" != 1 ];then
         if [ ! -f $tarball ]; then
         printf "${grn}Downloading rootfs, please wait,..${rst}\n"
         echo ""
               case `dpkg --print-architecture` in
               aarch64)
                       archurl="arm64" ;;
               arm*)
                       archurl="armhf" ;;
	       #x86)
	       #       archurl="i386" ;;
               x86_64)
                       archurl="amd64" ;;
               *)
                       echo "Unknown Architecture."; exit 1 ;;
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
bin=.ubuntu
linux=ubuntu
printf "\n"
printf "${ppl}Writing launch script.${rst}\n"
cat > $bin <<- EOM
#!/data/data/com.termux/files/usr/bin/bash
cd \$(dirname \$0)
## Start pulseaudio
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
## Unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" --kill-on-exit"
command+=" --sysvipc"
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
command+=" -b /sys"
## Uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## Uncomment the following line to mount /sdcard directly to /
command+=" -b /data"
command+=" -b /data/data/com.termux/files/usr/tmp:/tmp"
command+=" -b $folder/root:/dev/shm"
command+=" -b /sdcard"
command+=" -b /mnt"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
command+=" TMPDIR=/tmp"
command+=" TERM=${TERM-xterm-256color}"
command+=" MOZ_FAKE_NO_SANDBOX=1"
command+=" LC_ALL=C"
command+=" LANG=en_US.UTF-8"
command+=" LANGUAGE=en_US"
command+=" /bin/bash --login"
command+=" \$@"
if [ -z "\$1" ];then
   exec \$command
else
   \$command -c "\$com"
fi
EOM
     printf "\n"
     printf "${ylw}Fixing shebang of $linux.\n"
     termux-fix-shebang $bin
     printf "$ylw}Making $linux executable.\n"
     chmod +x $bin
     printf "${ylw}Fixing permissions $linux.\n"
     #chmod -R 755 $folder
     printf "${ylw}Removing rootfs of $linux.\n"
     #rm $tarball
     printf "\n"
     printf "${ppl}Updating Package,..${rst}\n"
     printf "\n"
echo "" > $folder/root/.hushlogin
#echo "TZ='Asia/Jakarta'; export TZ" >> $folder/root/.profile
echo "export PULSE_SERVER=127.0.0.1" >> $folder/root/.bashrc
echo 'bash .ubuntu' > $PREFIX/bin/$linux
chmod +x $PREFIX/bin/$linux
echo "#!/bin/bash
apt update ; apt upgrade -y
ln -s /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
apt install dialog nano sudo tzdata -y
rm -rf ~/.bash_profile
exit" > $folder/root/.bash_profile
bash $bin
#    clear
     printf "\n"
     printf "${cyn}You can login to Linux with '${grn}$linux${cyn}' script next time.${rst}\n"
     printf "\n"
     #rm ubuntu.sh
#
## Script edited by 'WaHaSa', Script revision-5.
#

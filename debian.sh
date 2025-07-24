#!/data/data/com.termux/files/usr/bin/bash
# <=> https://github.com/wahasa

# Debian Releases
# <=> https://debian.org
# <=> https://wiki.debian.org/DebianReleases

# Debian ELTS ( Extended Long Term Support )
# [+] stretch  09 ( Stretch )  - ( Release Date Jun 2017 / End of Support Jun 2027 )
# [+] buster   10 ( Buster )   - ( Release Date Jul 2019 / End of Support Jun 2029 )

# Debian LTS ( Long term support )
# [+] bullseye 11 ( Bullseye ) - ( Release Date Aug 2021 / End of Support Jun 2031 )

# Debian Lastest
# [+] bookworm 12 ( Bookworm ) - ( Release Date Jun 2023 / End of Support Jun 2033 )

# Debian Next
# [+] trixie   13 ( Trixie )   - ( Next Release )
# [+] testing     ( Development )

# Debian Repositories
# <=> http://ftp.debian.org/debian/dists

# Debian Rootfs
# <=> https://github.com/debuerreotype/docker-debian-artifacts
# <=> https://docker.debian.net
# <=> https://hub.docker.com/_/debian

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
printf "${blu} • Welcome To Debian Termux For Android\n"
printf "\n"
printf "${blu}List Code Name     Version     Recommended\n"
printf "${grn}[+]  ${ylw}trixie         ${wht}13.00          ${grn}yes\n"
printf "${grn}[+]  ${ylw}bookworm       ${wht}12.11          ${grn}yes\n"
printf "${grn}[+]  ${ylw}bullseye       ${wht}11.11          ${grn}yes\n"
printf "${red}[+]  ${red}buster         ${red}10.13          ${red}no\n"
printf "${blu}\n"
printf "${cyn}Select your debian < ${ylw}code name${cyn} > :${ylw}"
read -p " " debian

clear
bin=.debian
linux=debian
     printf "${rst}\n"
     printf "${grn}Installing $linux $debian,..\n"
     printf "${rst}\n"
     pkg install root-repo x11-repo
     pkg install proot neofetch pulseaudio -y
     #termux-setup-storage
echo ""
folder=debian-fs
neofetch --ascii_distro $linux -L
if [ -d "$folder" ]; then
         first=1
         printf "${red}Skipping Downloading.${rst}\n"
fi
tarball="debian-rootfs.tar.gz"
if [ "$first" != 1 ];then
         if [ ! -f $tarball ]; then
         printf "${grn}Downloading rootfs, please wait,..${rst}\n"
         echo ""
               case `dpkg --print-architecture` in
               aarch64)
                       archurl="arm64v8" ;;
               arm*)
                       archurl="arm32v7" ;;
               #i386)
	       #       archurl="i386" ;;
               #x86_64)
               #       archurl="amd64" ;;
               *)
                       echo "Unknown Architecture."; exit 1 ;;
               esac
	       wget "https://github.com/debuerreotype/docker-debian-artifacts/raw/refs/heads/dist-${archurl}/${debian}/oci/blobs/rootfs.tar.gz" -O $tarball
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
    printf "\n"
    printf "${ppl}Writing launch script.${rst}\n"
    printf "\n"

cat > $bin <<- EOM
#!/data/data/com.termux/files/usr/bin/bash
cd \$(dirname \$0)
## Audio output script in pulseaudio termux.
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
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
command+=" -b /proc/sys/kernel/cap_last_cap"
command+=" -b /proc/self/fd:/dev/fd"
command+=" -b /proc/self/fd/0:/dev/stdin"
command+=" -b /proc/self/fd/1:/dev/stdout"
command+=" -b /proc/self/fd/2:/dev/stderr"
command+=" -b /:/host-rootfs"
command+=" -b /sys"
command+=" -b /sys/fs/selinux"
command+=" -b $folder/tmp:/dev/shm"
## Uncomment the following line to get access to termux directory.
#command+=" -b /data/data/com.termux/files/home:/root"
## Uncomment the following line to mount sdcard directly to linux.
command+=" -b /sdcard"
command+=" -w /home/$linux"
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
     printf "${ylw}Fixing shebang of $linux.\n"
     termux-fix-shebang $bin
     printf "${ylw}Making executable $linux.\n"
     chmod +x $bin
     printf "${ylw}Fixing permissions $linux.\n"
     #chmod -R 755 $folder
     printf "${ylw}Removing rootfs in termux.\n"
     rm $tarball
     #clear
     printf "\n"
     printf "${red}Updating Package,..${rst}\n"
     printf "\n"

cp $folder/etc/skel/.bashrc $folder/home/$linux/
echo "TZ='Asia/Jakarta'; export TZ" >> $folder/home/$linux/.profile
echo "export PULSE_SERVER=127.0.0.1" >> $folder/home/$linux/.bashrc
#sed -i 's/32/31/g' $folder/home/$linux/.bashrc
echo "" > $folder/home/$linux/.hushlogin

cat > $PREFIX/bin/$linux <<- EOF
bash .$linux
EOF

chmod +x $PREFIX/bin/$linux
cat > $folder/home/$linux/.bash_profile <<- EOF
apt update ; apt upgrade -y
#ln -s /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
apt install dialog nano sudo tzdata -y
useradd -m -s /bin/bash $linux
echo "$linux:$linux" | chpasswd
echo "$linux  ALL=(ALL:ALL) ALL" > /etc/sudoers.d/$linux
rm -rf ~/.bash_profile
exit
EOF

bash $bin
cat > $PREFIX/bin/$linux <<- EOF
bash .$linux su $linux
EOF
     clear
     printf "\n"
     printf "${cyn}You can login to Linux with '${grn}$linux${cyn}' script next time.${rst}\n"
     printf "\n"
     #rm ubuntu.sh
#
## Script edited by 'WaHaSa', Script revision-6.
#

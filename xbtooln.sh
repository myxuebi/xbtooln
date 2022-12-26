#!/usr/bin/env bash
######
#脚本网站:shell.xb6868.com
#论坛:bbs.xb6868.com
#github:https://github.com/myxuebi/xbtooln
#shell_url="https://raw.githubusercontent.com/myxuebi/xbtooln/master/files"
shell_url="https://shell.xb6868.com/xbtool/files"
######
Y="\e[33m"
G="\e[32m"
R="\e[31m"
E="\e[0m"
######
#判断包管理程序并赋值
if [ ! $(command -v pacman) ];then
	if [ ! $(command -v apt) ];then
		echo -e "${R}Error:未检测到支持的包管理器${E}"
		exit
	else
		update_pkg="apt update"
		install_pkg="apt install"
		remove_pkg="apt remove"
		yes="-y"
	fi
else
	update_pkg="pacman -Syy"
	install_pkg="pacman -S"
	remove_pkg="pacman -R"
	yes="--noconfirm"
fi
######
#每日更新源
update_date=`date +"%D"`
if cat .update.log | grep -q $update_date
then
	sleep 0.1
else
    echo "每日更新源..."
	$update_pkg
	echo "$update_date" >>.update.log
fi
######
version(){
echo "beta 0.0.1
只有基础termux功能
2022/9/1

2022/9/30
beta 0.0.2
修复已知bug

2022/10/4
beta 0.0.3
新增electron功能，修复已知bug

2022/12/17
beta 0.0.4
修复已知bug
优化chromium安装方式

2022/12/26
beta 0.0.5
优化容器安装方式
增加chroot容器安装支持"
}
######
wget_check(){
if [ $? = 0 ];then
	echo -e "${G}下载成功...${E}"
else
	echo -e "${R}下载失败，请检查网络连接...${E}"
	exit
fi
}
######
#系统判断及依赖安装 
start(){
echo -e "${R}警告！您使用的是初始beta 版本，功能很少，有bug${E}"
sleep 3
for i in gawk dialog curl wget pulseaudio unzip
do if [ ! $(command -v $i) ];then
	$install_pkg $i $yes
fi done
if [ $(uname -o) = Android ];then
	termux
	exit
fi
SYS_V=$(cat /etc/os-release | gawk 'NR==1' | gawk -F '"' '{print $2}' | gawk '{print $1}')
case $SYS_V in
	Debian | Ubuntu)debian ;;
	Arch)echo "arch功能还没写好呢，亲~"
		exit ;;
	*)if [ ! $(command -v gawk) ]; then
		$install_pkg gawk $yes
		echo -e "${Y}尝试安装awk已完成，请重启脚本${E}"
		exit
	fi
	echo -e "${R}不受支持的系统${E}"
	exit ;;
esac
}
######
termux(){
input=$(dialog --title "Xbtooln Menu" --menu "选择一项" 0 0 0 1 termux换源 2 termux备份/恢复选项 3 Linux容器安装 4 二维码生成 5 关于脚本 --output-fd 1)
case $input in
	1)input=$(dialog --title "Mirror list" --menu "选择一个源地址" 0 0 0 1 北外源bfsu 2 清华源tuna 3 中科大源ustc 4 更多源选项-termux自带 5 返回上级菜单 --output-fd 1)
		case $input in
			1)mirror_url=mirrors.bfsu.edu.cn ;;
			2)mirror_url=mirrors.tuna.tsinghua.edu.cn ;;
			3)mirror_url=mirrors.ustc.edu.cn ;;
			4)termux-change-repo
				exit ;;
			5)termux
			exit ;;
		        *)exit ;;
		esac
		echo "deb https://$mirror_url/termux/apt/termux-main stable main" >>$PREFIX/etc/apt/sources.list
		apt update
		echo -e "${G}更换源已完成${E}"
		sleep 3
		termux ;;
	2)input=$(dialog --title "Termux Backup" --menu "注意：恢复数据可能会覆盖当前数据" 0 0 0 1 备份Termux数据 2 恢复Termux数据 3 返回上级菜单 --output-fd 1)
		case $input in
			1)cd /data/data/com.termux
			tar zcvf huifu.tar.gz files
			mv huifu.tar.gz /sdcard
			echo -e "${G}操作已完成,文件已保存至sdcard，如果没有文件请检查是否开启了存储权限${E}"
			sleep 3
			rm -rf huifu.tar.gz
			termux ;;
		2)file=$(dialog --title "选择你的恢复包文件" --fselect /sdcard/ 7 40 --output-fd 1)
			cd /data/data/com.termux/
			cp $file ./huifu.tar.gz
			tar zxvf huifu.tar.gz
			echo -e "${G}恢复完成${E}"
			sleep 3
			termux ;;
		3)termux
		exit ;;
	esac ;;
        3)input=$(dialog --title "Vessel Install" --menu "选择您要安装的容器类型\nchroot容器需要root权限" 0 0 0 1 Chroot 2 Proot 3 返回上级菜单 --output-fd 1)
		case $input in
			1)Chroot ;;
			2)Proot ;;
			*)termux ;;
		esac ;;
	4)test=$(dialog --title "QRCode" --inputbox "输入您要转换成二维码的内容（网址要带https://)：" 0 0 0 --output-fd 1)
		echo "${test}" |curl -F-=\<- qrenco.de
		echo "done.."
		sleep 3
		termux ;;
	5)input=$(dialog --title "About Xbtooln" --menu " " 0 0 0 1 更新日志 2 加入Q群 3 访问论坛 4 BUG反馈 5 返回上级菜单 --output-fd 1)
		case $input in
		1)version
			echo 按回车键继续
			read enter
			termux ;;
		2)am start mqqopensdkapi://bizAgent/qm/qr?url=https%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Fk%3DsggIpVFslC89hhAN9SIke6-5nDYOQytZ%26jump_from%3D%26auth%3D%26app_name%3D%26authSig%3DF4hbz11Ha0k86L%2B4u97r0O6iUpJGPoExq8o3LbvCjFUof3YBRzTRkaCeHiUE43LF%26source_id%3D3_40001
			echo "如果termux没有自动跳转，请手动加入qq群，群号：769436389"
			sleep 5
			termux ;;
		3)am start -a android.intent.action.VIEW -d https://bbs.xb6868.com/
			echo "如果没有自动跳转，请手动访问https://bbs.xb6868.com/"
			sleep 4
			termux ;;
		4)am start -a android.intent.action.VIEW -d https://github.com/myxuebi/xbtooln/issues
			echo "如果没有自动跳转，请手动访问https://github.com/myxuebi/xbtooln/issues"
			sleep 5
			termux ;;
		5)termux ;;
		*)exit ;;
	esac
esac
}
######
#容器安装
vessel(){
proot_system=$(dialog --title "$vessel_ Install" --menu "选择你要安装的Proot容器" 0 0 0 ubuntu 乌班图 debian 致力于自由 archlinux YYDS！ --output-fd 1)
ver=$(curl https://mirrors.bfsu.edu.cn/lxc-images/images/${proot_system}/ | gawk -F ">" '{print $3}' | grep title | gawk '{print $2}' | gawk -F '"' '{print $2}' | sed 's/\///')
for i in cosmic disco eoan groovy hirstue trusty
do ver=$(echo "$ver" | sed "/^$i/d")
done
ver=$(echo "$ver" | cat -n | gawk '{print $2,$1}')
case $proot_system in
	ubuntu | debian)proot_ver=$(dialog --title "$vessel_ Install" --menu "选择一个版本安装容器" 0 0 0 $ver --output-fd 1) ;;
	archlinux)proot_ver="current" ;;
	*)exit ;;
esac
if [ ! $(echo "$proot_ver") ];then
	exit
fi
if [ -e .${proot_system}-${proot_ver} ];then
	echo -e "你已安装过此系统，不可再次安装"
	exit
fi
#for i in cosmic disco eoan groovy hirstue trusty
#do	if [ $proot_ver = $i ]; then
#		dialog --title Error --msgbox "暂不支持此版本\n不支持的版本有：cosmic disco eoan groovy hirstue trusty" 0 0
#		vessel
#		exit
#	fi
#done	
DOWN_LINE=$(curl https://mirrors.bfsu.edu.cn/lxc-images/images/${proot_system}/${proot_ver}/arm64/default/ | gawk '{print $3}' | tail -n 3 | head -n 1 | gawk -F '"' '{print $2}' | gawk -F '/' '{print $1}')
rm rootfs.tar.xz
wget https://mirrors.bfsu.edu.cn/lxc-images/images/${proot_system}/${proot_ver}/arm64/default/${DOWN_LINE}/rootfs.tar.xz -t 4
wget_check
mkdir .${proot_system}-${proot_ver}
tar xvf rootfs.tar.xz -C .${proot_system}-${proot_ver}
rm rootfs.tar.xz
rm .${proot_system}-${proot_ver}/etc/resolv.conf
echo "nameserver 114.114.114.114
nameserver 114.114.115.115" >>.${proot_system}-${proot_ver}/etc/resolv.conf
case $proot_system in
     ubuntu)sed -i 's/ports.ubuntu.com/mirrors.ustc.edu.cn/g' .${proot_system}-${proot_ver}/etc/apt/sources.list ;;
	 debian)sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' .${proot_system}-${proot_ver}/etc/apt/sources.list ;;
	 archlinux)echo 'Server = https://mirrors.ustc.edu.cn/archlinuxarm/$arch/$repo' >.${proot_system}-${proot_ver}/etc/pacman.d/mirrorlist
	 echo '[archlinuxcn]
    Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch' >>.${proot_system}-${proot_ver}/etc/pacman.conf ;;
esac
echo ". run.sh" >>.${proot_system}-${proot_ver}/etc/profile
echo "proot_system=${proot_system}" >>.${proot_system}-${proot_ver}/root/run.sh
cat >>.${proot_system}-${proot_ver}/root/run.sh<<-'eof'
case $proot_system in
	ubuntu | debian)apt update
	                apt install apt-transport-https
	                perln=$(ls /usr/bin | grep perl | grep "[0-9]$")
	                ln -s /usr/bin/$perln /usr/bin/perl
	                apt install ca-certificates -y
	                sed -i 's/http/https/g' /etc/apt/sources.list
	                apt update
	                touch ${HOME}/.hushlogin
			apt install vim fonts-wqy-zenhei tar pulseaudio curl wget gawk whiptail locales busybox -y
             mv /var/lib/dpkg/info/ /var/lib/dpkg/info_old/&&mkdir /var/lib/dpkg/info/&&apt-get update&&apt-get -f install&&mv /var/lib/dpkg/info/* /var/lib/dpkg/info_old/&&mv /var/lib/dpkg/info /var/lib/dpkg/info_back&&mv /var/lib/dpkg/info_old/ /var/lib/dpkg/info
		apt install
		yes | apt reinstall sudo;;
		archlinux)chmod -R 755 /etc
			chmod 440 /etc/sudoers
			chmod -R 755 /usr
			chmod -R 755 /var
			sed -i 's/C/zh_CN.UTF-8/g' /etc/locale.conf
			pacman -Sy curl wget tar pulseaudio curl gawk libnewt dialog wqy-zenhei vim nano busybox --noconfirm ;;
esac
eof
}
######
#Chroot安装
Chroot(){
vessel_="Chroot"
apt install busybox tsu -y
if [ $(sudo id -u) -ne 0 ];then
	echo "未检测到root权限，操作结束"
fi
CREATE_USER=$(dialog --title "请输入用户名" --inputbox "请输入你要创建普通用户的用户名\n必须输入，且输入英文，否则可能出现异常" 0 0 0 --output-fd 1)
if [ ! $(echo $CREATE_USER) ];then
	echo -e "$R请输入一个用户名，否则安装无法继续$E"
	exit
fi
vessel
sed -i '1i\echo "开始配置系统"\nsleep 3\nbash auth-ad.sh' .${proot_system}-${proot_ver}/root/run.sh
sed -i "1i\export CREATE_USER=$CREATE_USER" .${proot_system}-${proot_ver}/root/run.sh
cat >>.${proot_system}-${proot_ver}/root/auth-ad.sh<<-'eof'
groupadd -g 0 AID_ROOT
groupadd -g 1 AID_DAEMON
groupadd -g 2 AID_BIN
groupadd -g 3 AID_SYS
groupadd -g 1000 AID_SYSTEM
groupadd -g 1001 AID_RADIO
groupadd -g 1002 AID_BLUETOOTH
groupadd -g 1003 AID_GRAPHICS
groupadd -g 1004 AID_INPUT
groupadd -g 1005 AID_AUDIO
groupadd -g 1006 AID_CAMERA
groupadd -g 1007 AID_LOG
groupadd -g 1008 AID_COMPASS
groupadd -g 1009 AID_MOUNT
groupadd -g 1010 AID_WIFI
groupadd -g 1011 AID_ADB
groupadd -g 1012 AID_INSTALL
groupadd -g 1013 AID_MEDIA
groupadd -g 1014 AID_DHCP
groupadd -g 1015 AID_SDCARD_RW
groupadd -g 1016 AID_VPN
groupadd -g 1017 AID_KEYSTORE
groupadd -g 1018 AID_USB
groupadd -g 1019 AID_DRM
groupadd -g 1020 AID_MDNSR
groupadd -g 1021 AID_GPS
groupadd -g 1022 AID_UNUSED1
groupadd -g 1023 AID_MEDIA_RW
groupadd -g 1024 AID_MTP
groupadd -g 1025 AID_UNUSED2
groupadd -g 1026 AID_DRMRPC
groupadd -g 1027 AID_NFC
groupadd -g 1028 AID_SDCARD_R
groupadd -g 1029 AID_CLAT
groupadd -g 1030 AID_LOOP_RADIO
groupadd -g 1031 AID_MEDIA_DRM
groupadd -g 1032 AID_PACKAGE_INFO
groupadd -g 1033 AID_SDCARD_PICS
groupadd -g 1034 AID_SDCARD_AV
groupadd -g 1035 AID_SDCARD_ALL
groupadd -g 1036 AID_LOGD
groupadd -g 1037 AID_SHARED_RELRO
groupadd -g 1038 AID_DBUS
groupadd -g 1039 AID_TLSDATE
groupadd -g 1040 AID_MEDIA_EX
groupadd -g 1041 AID_AUDIOSERVER
groupadd -g 1042 AID_METRICS_COLL
groupadd -g 1043 AID_METRICSD
groupadd -g 1044 AID_WEBSERV
groupadd -g 1045 AID_DEBUGGERD
groupadd -g 1046 AID_MEDIA_CODEC
groupadd -g 1047 AID_CAMERASERVER
groupadd -g 1048 AID_FIREWALL
groupadd -g 1049 AID_TRUNKS
groupadd -g 1050 AID_NVRAM
groupadd -g 1051 AID_DNS
groupadd -g 1052 AID_DNS_TETHER
groupadd -g 1053 AID_WEBVIEW_ZYGOTE
groupadd -g 1054 AID_VEHICLE_NETWORK
groupadd -g 1055 AID_MEDIA_AUDIO
groupadd -g 1056 AID_MEDIA_VIDEO
groupadd -g 1057 AID_MEDIA_IMAGE
groupadd -g 1058 AID_TOMBSTONED
groupadd -g 1059 AID_MEDIA_OBB
groupadd -g 1060 AID_ESE
groupadd -g 1061 AID_OTA_UPDATE
groupadd -g 1062 AID_AUTOMOTIVE_EVS
groupadd -g 1063 AID_LOWPAN
groupadd -g 1064 AID_HSM
groupadd -g 1065 AID_RESERVED_DISK
groupadd -g 1066 AID_STATSD
groupadd -g 1067 AID_INCIDENTD
groupadd -g 1068 AID_SECURE_ELEMENT
groupadd -g 1069 AID_LMKD
groupadd -g 1070 AID_LLKD
groupadd -g 1071 AID_IORAPD
groupadd -g 1072 AID_GPU_SERVICE
groupadd -g 1073 AID_NETWORK_STACK
groupadd -g 1074 AID_GSID
groupadd -g 1075 AID_FSVERITY_CERT
groupadd -g 1076 AID_CREDSTORE
groupadd -g 1077 AID_EXTERNAL_STORAGE
groupadd -g 1078 AID_EXT_DATA_RW
groupadd -g 1079 AID_EXT_OBB_RW
groupadd -g 1080 AID_CONTEXT_HUB
groupadd -g 1081 AID_VIRTUALIZATIONSERVICE
groupadd -g 1082 AID_ARTD
groupadd -g 1083 AID_UWB
groupadd -g 1084 AID_THREAD_NETWORK
groupadd -g 1085 AID_DICED
groupadd -g 1086 AID_DMESGD
groupadd -g 1087 AID_JC_WEAVER
groupadd -g 1088 AID_JC_STRONGBOX
groupadd -g 1089 AID_JC_IDENTITYCRED
groupadd -g 1090 AID_SDK_SANDBOX
groupadd -g 1091 AID_SECURITY_LOG_WRITER
groupadd -g 1092 AID_PRNG_SEEDER
groupadd -g 2000 AID_SHELL
groupadd -g 2001 AID_CACHE
groupadd -g 2002 AID_DIAG
groupadd -g 2900 AID_OEM_RESERVED_START
groupadd -g 2999 AID_OEM_RESERVED_END
groupadd -g 3001 AID_NET_BT_ADMIN
groupadd -g 3002 AID_NET_BT
groupadd -g 3003 AID_INET
groupadd -g 3004 AID_NET_RAW
groupadd -g 3005 AID_NET_ADMIN
groupadd -g 3006 AID_NET_BW_STATS
groupadd -g 3007 AID_NET_BW_ACCT
groupadd -g 3009 AID_READPROC
groupadd -g 3010 AID_WAKELOCK
groupadd -g 3011 AID_UHID
groupadd -g 3012 AID_READTRACEFS
groupadd -g 5000 AID_OEM_RESERVED_2_START
groupadd -g 5999 AID_OEM_RESERVED_2_END
groupadd -g 6000 AID_SYSTEM_RESERVED_START
groupadd -g 6499 AID_SYSTEM_RESERVED_END
groupadd -g 6500 AID_ODM_RESERVED_START
groupadd -g 6999 AID_ODM_RESERVED_END
groupadd -g 7000 AID_PRODUCT_RESERVED_START
groupadd -g 7499 AID_PRODUCT_RESERVED_END
groupadd -g 7500 AID_SYSTEM_EXT_RESERVED_START
groupadd -g 7999 AID_SYSTEM_EXT_RESERVED_END
groupadd -g 9997 AID_EVERYBODY
groupadd -g 9998 AID_MISC
groupadd -g 9999 AID_NOBODY
groupadd -g 10000 AID_APP
groupadd -g 10000 AID_APP_START
groupadd -g 19999 AID_APP_END
groupadd -g 20000 AID_CACHE_GID_START
groupadd -g 29999 AID_CACHE_GID_END
groupadd -g 30000 AID_EXT_GID_START
groupadd -g 39999 AID_EXT_GID_END
groupadd -g 40000 AID_EXT_CACHE_GID_START
groupadd -g 49999 AID_EXT_CACHE_GID_END
groupadd -g 50000 AID_SHARED_GID_START
groupadd -g 59999 AID_SHARED_GID_END
groupadd -g 65534 AID_OVERFLOWUID
groupadd -g 20000 AID_SDK_SANDBOX_PROCESS_START
groupadd -g 29999 AID_SDK_SANDBOX_PROCESS_END
groupadd -g 90000 AID_ISOLATED_START
groupadd -g 99999 AID_ISOLATED_END
groupadd -g 100000 AID_USER
groupadd -g 100000 AID_USER_OFFSET
usermod -g 3003 -G 3003,3004 -a _apt
useradd -m ${CREATE_USER} 
sed -i /${CREATE_USER}/s/sh/bash/ /etc/passwd
echo "设置${CREATE_USER}用户密码"
passwd ${CREATE_USER}
echo "设置root用户密码"
passwd
chmod 755 /
chmod 755 /bin /usr /home /media /opt /sbin /srv /tmp /var /boot /etc /lib /mnt /run /proc /sys /dev
chmod 755 -R /usr
chmod 755 /etc/bash.bashrc
chmod 644 /etc/passwd
chmod 755 /etc/profile
for i in root ${CREATE_USER}
do usermod -a -G AID_ROOT,AID_DAEMON,AID_BIN,AID_SYS,AID_SYSTEM,AID_RADIO,AID_BLUETOOTH,AID_GRAPHICS,AID_INPUT,AID_AUDIO,AID_CAMERA,AID_LOG,AID_COMPASS,AID_MOUNT,AID_WIFI,AID_ADB,AID_INSTALL,AID_MEDIA,AID_DHCP,AID_SDCARD_RW,AID_VPN,AID_KEYSTORE,AID_USB,AID_DRM,AID_MDNSR,AID_GPS,AID_UNUSED1,AID_MEDIA_RW,AID_MTP,AID_UNUSED2,AID_DRMRPC,AID_NFC,AID_SDCARD_R,AID_CLAT,AID_LOOP_RADIO,AID_MEDIA_DRM,AID_PACKAGE_INFO,AID_SDCARD_PICS,AID_SDCARD_AV,AID_SDCARD_ALL,AID_LOGD,AID_SHARED_RELRO,AID_DBUS,AID_TLSDATE,AID_MEDIA_EX,AID_AUDIOSERVER,AID_METRICS_COLL,AID_METRICSD,AID_WEBSERV,AID_DEBUGGERD,AID_MEDIA_CODEC,AID_CAMERASERVER,AID_FIREWALL,AID_TRUNKS,AID_NVRAM,AID_DNS,AID_DNS_TETHER,AID_WEBVIEW_ZYGOTE,AID_VEHICLE_NETWORK,AID_MEDIA_AUDIO,AID_MEDIA_VIDEO,AID_MEDIA_IMAGE,AID_TOMBSTONED,AID_MEDIA_OBB,AID_ESE,AID_OTA_UPDATE,AID_AUTOMOTIVE_EVS,AID_LOWPAN,AID_HSM,AID_RESERVED_DISK,AID_STATSD,AID_INCIDENTD,AID_SECURE_ELEMENT,AID_LMKD,AID_LLKD,AID_IORAPD,AID_GPU_SERVICE,AID_NETWORK_STACK,AID_GSID,AID_FSVERITY_CERT,AID_CREDSTORE,AID_EXTERNAL_STORAGE,AID_EXT_DATA_RW,AID_EXT_OBB_RW,AID_CONTEXT_HUB,AID_VIRTUALIZATIONSERVICE,AID_ARTD,AID_UWB,AID_THREAD_NETWORK,AID_DICED,AID_DMESGD,AID_JC_WEAVER,AID_JC_STRONGBOX,AID_JC_IDENTITYCRED,AID_SDK_SANDBOX,AID_SECURITY_LOG_WRITER,AID_PRNG_SEEDER,AID_SHELL,AID_CACHE,AID_DIAG,AID_OEM_RESERVED_START,AID_OEM_RESERVED_END,AID_NET_BT_ADMIN,AID_NET_BT,AID_INET,AID_NET_RAW,AID_NET_ADMIN,AID_NET_BW_STATS,AID_NET_BW_ACCT,AID_READPROC,AID_WAKELOCK,AID_UHID,AID_READTRACEFS,AID_OEM_RESERVED_2_START,AID_OEM_RESERVED_2_END,AID_SYSTEM_RESERVED_START,AID_SYSTEM_RESERVED_END,AID_ODM_RESERVED_START,AID_ODM_RESERVED_END,AID_PRODUCT_RESERVED_START,AID_PRODUCT_RESERVED_END,AID_SYSTEM_EXT_RESERVED_START,AID_SYSTEM_EXT_RESERVED_END,AID_EVERYBODY,AID_MISC,AID_NOBODY,AID_APP,AID_APP_START,AID_APP_END,AID_CACHE_GID_START,AID_CACHE_GID_END,AID_EXT_GID_START,AID_EXT_GID_END,AID_EXT_CACHE_GID_START,AID_EXT_CACHE_GID_END,AID_SHARED_GID_START,AID_SHARED_GID_END,AID_OVERFLOWUID,AID_SDK_SANDBOX_PROCESS_START,AID_SDK_SANDBOX_PROCESS_END,AID_ISOLATED_START,AID_ISOLATED_END,AID_USER,AID_USER_OFFSET $i
done
eof
cat >>.${proot_system}-${proot_ver}/root/run.sh<<-'eof'
echo "${CREATE_USER} ALL=(ALL:ALL) ALL" >> /etc/sudoers
chown root:root /etc/sudo.conf -R
chown -R root:root /bin/su
chmod u+s /bin/su
chown -R root:root /etc/sudoers.d
sed -i /zh_CN/s/#// /etc/locale.gen
locale-gen
sed -i 's/. run.sh//g' /etc/profile
echo "export LANG=zh_CN.UTF-8
export PULSE_SERVER=127.0.0.1
pulseaudio --start >/dev/null 2>&1" >>/etc/profile
echo "配置已完成"
eof
echo "CREATE_USER=$CREATE_USER
proot_system=${proot_system}
proot_ver=${proot_ver}" >${proot_ver}-chroot.sh
cat>>${proot_ver}-chroot.sh<<-'eof'
#!/usr/bin/env bash
unset LD_PRELOAD
case $1 in
	-remove)for i in .${proot_system}-${proot_ver}/proc .${proot_system}-${proot_ver}/dev/pts .${proot_system}-${proot_ver}/sys .${proot_system}-${proot_ver}/dev
		do sudo umount $i
		if [ $? = 0 ];then
			sleep 0.1
		else
			echo 错误，无法取消挂载，请手动取消挂载然后手动执行rm -rf .${proot_system}-${proot_ver} ${proot_ver}-chroot.sh
			exit
		fi
	        done
		echo 即将开始删除容器，若发现异常，请立即按下Ctrl-c停止运行脚本，及时止损
		echo 请确认所有挂载均已解除，若未解除请立即按下Ctrl-c停止运行脚本
		sleep 5
		sudo rm -rfv .${proot_system}-${proot_ver} ${proot_ver}-chroot.sh
		echo 卸载完成 ;;
	*)if [ ! $(sudo mount | grep termux) ];then
	        for i in proc dev sys dev/pts
		do sudo mount /$i .${proot_system}-${proot_ver}/$i
		done
		sudo mount -o remount,suid /data
	fi
		sudo $PREFIX/bin/busybox chroot .${proot_system}-${proot_ver}/ /bin/su - ${CREATE_USER} ;;
esac
eof
if [ $proot_ver = current ];then
    mv current-chroot.sh arch-chroot.sh
    proot_ver="arch"
fi
chmod 777 ${proot_ver}-chroot.sh
unset LD_PRELOAD
sudo mount -o remount,suid /data
for i in proc dev sys dev/pts
do sudo mount /$i .${proot_system}-${proot_ver}/$i
done
sudo $PREFIX/bin/busybox chroot .${proot_system}-${proot_ver}/ /bin/su - root
echo -e "${Y}输入./$proot_ver-chroot.sh可再次启动启动容器${E}
输入./$proot_ver-chroot.sh -remove可卸载容器"
}
######
#Proot安装
Proot(){
vessel_="Proot"
apt install proot -y
vessel
sed -i '1i\echo "开始配置系统"\nsleep 3' .${proot_system}-${proot_ver}/root/run.sh
mkdir -p .${proot_system}-${proot_ver}/etc/proc
echo "$(uname -a | sed 's/Android/Xbtooln/g')" >>.${proot_system}-${proot_ver}/etc/proc/version
rm proc.tar.gz
wget ${shell_url}/proc.tar.gz -t 4
wget_check
tar zxvf proc.tar.gz -C .${proot_system}-${proot_ver}/etc/proc/
rm rootfs.tar.xz proc.tar.gz
cat >>.${proot_system}-${proot_ver}/root/run.sh<<-'eof'
for i in ps pstree top uptime pkill egrep killall ifconfig
do ln -sf /bin/busybox /bin/$i
done
sed -i /zh_CN/s/#// /etc/locale.gen
locale-gen
sed -i 's/. run.sh//g' /etc/profile
echo "export LANG=zh_CN.UTF-8
export PULSE_SERVER=127.0.0.1
pulseaudio --start >/dev/null 2>&1" >>/etc/profile
echo "配置已完成"
eof
echo "pkill -9 pulseaudio 2>/dev/null
pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1 &
unset LD_PRELOAD
proot -l --sysvipc --kill-on-exit -S .${proot_system}-${proot_ver} -b .${proot_system}-${proot_ver}/root:/dev/shm -b .${proot_system}-${proot_ver}/etc/proc/vmstat:/proc/vmstat -b .${proot_system}-${proot_ver}/etc/proc/stat:/proc/stat -b .${proot_system}-${proot_ver}/etc/proc/buddyinfo:/proc/buddyinfo -b .${proot_system}-${proot_ver}/etc/proc/cmdline:/proc/cmdline -b .${proot_system}-${proot_ver}/etc/proc/key-users:/proc/key-users -b .${proot_system}-${proot_ver}/etc/proc/loadavg:/proc/loadavg -b .${proot_system}-${proot_ver}/etc/proc/cgroups:/proc/cgroups -b .${proot_system}-${proot_ver}/etc/proc/fb:/proc/fb -b .${proot_system}-${proot_ver}/etc/proc/keys:/proc/keys -b .${proot_system}-${proot_ver}/etc/proc/version:/proc/version -b /sdcard:/sdcard -b /sdcard:/root/sdcard -w /root /usr/bin/env -i LANG=zh_CN.UTF-8 HOME=/root USER=root TERM=xterm-256color PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games /bin/bash --login" >>${proot_ver}.sh
if [ $proot_ver = current ];then
    mv current.sh arch.sh
    proot_ver="arch"
fi
chmod 777 ${proot_ver}.sh
./${proot_ver}.sh
echo -e "${Y}输入./$proot_ver.sh可再次启动启动容器${E}"
exit
}
######
debian(){
if (( $(id -u) == 0 )); then
  sleep 0.1
else
  echo -e "\e[33m非root用户，为保障脚本完美运行，请使用root用户启动脚本\e[0m"
  read -r -p "1)继续运行脚本 2)停止运行脚本 3)尝试使用root用户启动脚本 请选择：" input
  case $input in
	  1)sleep 0.1 ;;
	  2)exit ;;
	  3)sudo bash -c "$(curl ${shell_url}/xbtools.sh)"
         exit ;;
 esac
fi
system=$(cat /etc/os-release | grep ^ID | gawk 'NR==1' | gawk -F '=' '{print $2}')
if [ $system = debian ];then
      codename=$(cat /etc/os-release | grep PRETTY | gawk -F '"' '{print $2}' | gawk -F "/" '{print $3}')
else
      codename=$(cat /etc/os-release | grep VERSION_CODENAME | gawk -F '=' '{print $2}')
fi
arch=$(uname -m)
input=$(dialog --title "Debian Menu" --menu "选择一项功能开始" 0 0 0 1 更换软件源 2 设置系统中文语言 3 软件安装 --output-fd 1)
case $input in
     1)input=$(dialog --title "Change Mirror" --menu "选择你要更换的源地址" 0 0 0 1 北外源bfsu 2 中科大源ustc 3 清华源tuna 4 返回上级目录 --output-fd 1)
	 case $input in
	  1)mirror_url="mirrors.bfsu.edu.cn" ;;
	  2)mirror_url="mirrors.ustc.edu.cn" ;;
	  3)mirror_url="mirrors.tuna.tsinghua.edu.cn" ;;
	  4)debian ;;
	  *)exit ;;
     esac
      case $system in
	      [uU]buntu)apt install apt-transport-https ca-certificates
	     if [ $(uname -m) = x86_64 ];then
		     mirror_path="ubuntu"
	     else
		     mirror_path="ubuntu-ports"
	     fi
	     case $codename in
		     trusty | xenial | bionic | focal | hirsute | impish | jammy)sleep 0.1 ;;
		     *)echo -e "${R}不受支持的版本${E}"
			     sleep 3
			     debian
			     exit;;
	     esac
	     echo "deb https://${mirror_url}/${mirror_path}/ ${codename} main restricted universe multiverse
	     deb https://${mirror_url}/${mirror_path}/ ${codename}-updates main restricted universe multiverse
	     deb https://${mirror_url}/${mirror_path}/ ${codename}-backports main restricted universe multiverse
	     deb https://${mirror_url}/${mirror_path}/ ${codename}-security main restricted universe multiverse" >/etc/apt/sources.list
	     apt update
	     echo -e "${G}done...${E}"
	     sleep 3
	     debian ;;
             [Dd]ebian)case $codename in
		     sid)echo "deb http://${mirror_url}/debian/ sid main contrib non-free" >/etc/apt/sources.list ;;
		     jessie)echo "deb http://${mirror_url}/debian/ jessie main contrib non-free
			     deb http://${mirror_url}/debian/ jessie-updates main contrib non-free
			     deb http://${mirror_url}/debian-security jessie/updates main contrib non-free" >/etc/apt/sources.list ;;
		     testing | bullseye | buster | stretch)echo "deb https://${mirror_url}/debian/ ${codename} main contrib non-free
			     deb http://${mirror_url}/debian/ ${codename}-updates main contrib non-free
			     deb http://${mirror_url}/debian/ ${codename}-backports main contrib non-free
			     deb http://${mirror_url}/debian-security ${codename}/updates main contrib non-free" >/etc/apt/sources.list ;;
		     *)echo -e "${R}不支持你的系统${E}"
			     sleep 3
			     debian
			     exit ;;
	     esac
	     apt update
	     perln=$(ls /usr/bin | grep perl | grep "[0-9]$")
	     ln -s /usr/bin/$perln /usr/bin/perl
	     apt install ca-certificates
	     sed -i 's/http/https/g' /etc/apt/sources.list
	     apt update
	     echo -e "${G}done..${E}"
	     sleep 3
	     debian ;;
	   esac ;;
     2)apt install fonts-wqy-zenhei
       sed -i /zh_CN/s/#// /etc/locale.gen
       locale-gen
       echo -e "${G}更换完成${E}"
       sleep 3 ;;
     3)app_install ;;
esac
}
######
app_install(){
input=$(dialog --title "App Install" --menu "选择你要安装的软件" 0 0 0 1 安装chroium浏览器 2 安装wine 3 electron软件安装 4 图形化界面安装 5 返回上级菜单 --output-fd 1)
case $input in
	1)case $system in
		[Uu]buntu)apt install xdg-utils -y
		          if [ $arch = aarch64 ]; then
				  arch1=arm64
			  fi
			  if [ $arch = x86_64 ]; then
				  arch1=amd64
			  fi
		          cversion=$(curl https://mirrors.ustc.edu.cn/ubuntu/pool/universe/c/chromium-browser/ | grep '^<a' | grep browser | gawk -F '_' '{print $2}' | gawk -F '-' '{print $1}' | grep '[0-9]$' | sort -g | awk 'END {print}')
			       uversion=$(curl https://mirrors.ustc.edu.cn/ubuntu/pool/universe/c/chromium-browser/ | grep '^<a' | grep browser | gawk -F '_' '{print $2}' | grep 108.0.5359.71 | gawk -F '-' '{print $2}' | gawk 'NR==1')
			       for i in chromium-browser-l10n_${cversion}-${uversion}_all.deb
			       do wget https://mirrors.ustc.edu.cn/ubuntu/pool/universe/c/chromium-browser/$i -t 4
				       wget_check
				       dpkg -i $i
				       rm $i
			       done
			      apt --fix-broken install -y
			      dialog --title "是否启用nosandbox" --yesno "是否启用--no-sandbox选项\n如果你是使用proot容器或者使用root用户登录的桌面请选择yes\n如果chromium无法正常启动请选择yes" 0 0
			      if [ $? = 0 ];then
			      sed -i '/Exec/s/chromium-browser/chromium-browser --no-sandbox/' /usr/share/applications/chromium-browser.desktop
			      fi ;;
		[dD]ebian)apt install chromium -y
			dialog --title "yes/no" --yesno "是否启用--no-sandbox选项\n如果你是使用proot容器或者使用root用户登录的桌面请选择yes\n如果chromium无法正常启动请选择yes" 0 0
			if [ $? = 0 ];then
			sed -i '/Exec/s/chromium/chromium --no-sandbox/' /usr/share/applications/chromium.desktop
			fi ;;
	  esac
	  echo -e "${G}安装完成...${E}"
	  sleep 3
	  app_install ;;
        2)case $arch in
		aarch64)dialog --title "yes/no" --yesno "安装wine会安装box64、box86，wine\n安装后可能会导致兼容性或系统错误，是否继续？" 0 0
		if [ $? = 0 ];then
			sleep 0.1
		else
			debian
			exit
		fi
		input=$(dialog --title "选择你要安装的wine版本" --menu "Ps：高版本在proot里可能会有bug" 0 0 0 1 wine3.9-推荐 2 wine6.14 --output-fd 1)
		case $input in
			1)down_url="https://shell.xb6868.com/wine/PlayOnLinux-wine-3.9-upstream-linux-amd64.tar.gz" ;;
			2)down_url="https://shell.xb6868.com/wine/PlayOnLinux-wine-6.17-upstream-linux-amd64.tar.gz" ;;
			*)exit ;;
		esac
		dpkg --add-architecture armhf && apt update
		apt install zenity:armhf libstdc++6:armhf gcc-arm-linux-gnueabihf mesa*:armhf libasound*:armhf -y
		apt install git cmake build-essential -y
		git_check(){
		for i in box64 box86
		do if [ -d $i ];then
			sleep 0.1
		else
			git clone http://github.com/ptitSeb/$i
			echo -e "${Y}正在尝试克隆仓库...${E}"
			sleep 2
			git_check
		fi;done
		}
		git_check
		cd box86 && mkdir build && cd build &&cmake .. -DRPI4ARM64=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo; make -j4 && make install
		cd && cd box64 && mkdir build; cd build; cmake .. -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo; make -j$(nproc) && make install
		cd && rm -rf box64 box86
		wget $down_url -O wine.tar.gz -t 4
		wget_check
		tar wine.tar.gz -C /usr
		echo -e"${Y}安装已经结束，使用方法如下：${E}
		wine3.9版本启动指令：box64 wine64 winecfg
		box64 wine64 explorer
		box64 wine64 taskmgr
		wine6.14启动指令：
		box64 wine64 taskmgr &
		sleep 5
		pkill services &"
		echo -e "${G}按下回车键继续${E}"
		read enter ;;
	x86_64)apt install wine -y ;;
          esac
	 app_install ;;
        3)sudo bash -c "$(curl ${shell_url}/electron.sh)"
		debian ;;
	4)gui_install ;;
	*)debian ;;
esac
}
######
gui_install(){
input=$(dialog --title "GUI Install" --menu "选择一项来安装图形" 0 0 0 1 xfce 2 kde 3 lxde 4 mate 5 返回上级菜单 --output-fd 1)
case $input in
	1)xstartup="startxfce4"
        apt install xfce4 xfce4-terminal ristretto dbus-x11 lxtask -y ;;
        2)xstartup="startkde"
	apt install kde-plasma-desktop dbus-x11 lxtask -y ;;
        3)xstartup="startlxde"
        apt install lxde-core lxterminal dbus-x11 -y ;;
        4)xstartup="mate-session"
        apt install mate-desktop-environment-core -y ;;
	*)app_install
		exit ;;
esac
mv /var/lib/dpkg/info/ /var/lib/dpkg/info_old/&&mkdir /var/lib/dpkg/info/&&apt-get update&&apt-get -f install&&mv /var/lib/dpkg/info/* /var/lib/dpkg/info_old/&&mv /var/lib/dpkg/info /var/lib/dpkg/info_back&&mv /var/lib/dpkg/info_old/ /var/lib/dpkg/info
dialog --title "yes/no" --yesno "是否安装vnc server服务" 0 0
if [ $? = 0 ];then
	sleep 0.1
else
	echo -e "${G}安装已完成....${E}"
	sleep 3
	app_install
	exit
fi
apt install
apt install tigervnc* -y
mv /var/lib/dpkg/info/ /var/lib/dpkg/info_old/&&mkdir /var/lib/dpkg/info/&&apt-get update&&apt-get -f install&&mv /var/lib/dpkg/info/* /var/lib/dpkg/info_old/&&mv /var/lib/dpkg/info /var/lib/dpkg/info_back&&mv /var/lib/dpkg/info_old/ /var/lib/dpkg/info
mkdir ${HOME}/.vnc
echo "$xstartup" >>${HOME}/.vnc/xstartup
chmod 777 ${HOME}/.vnc/xstartup
echo -e "${Y}设置vnc密码，设置完毕后，输入y再输一次${E}"
vncpasswd
if cat /proc/version | grep -q Xbtooln
then echo "tigervncserver :1" >>/usr/bin/start-vnc
else echo "export PULSE_SERVER=127.0.0.1
pulseaudio --start >/dev/null 2>&1
tigervncserver :1" >>/usr/bin/start-vnc
fi
chmod 777 /usr/bin/start-vnc
echo "安装已完成，输入start-vnc启动vnc"
echo -e "${G}按回车键继续${E}"
read enter
app_install
}
######
start
